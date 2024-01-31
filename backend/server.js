const express = require("express");
const mysql = require("mysql");
const bcrypt = require("bcrypt");
var jwt = require("jsonwebtoken");
const dotenv = require("dotenv");
const { promisify } = require("util");
const morgan = require("morgan");
dotenv.config();

const app = express();
app.use(express.json());
app.use(morgan("dev"));

// Create connection
const connection = mysql.createConnection({
  host: process.env.host,
  user: process.env.user,
  password: process.env.password,
  database: process.env.database,
  port: process.env.port,
});

connection.connect((err) => {
  if (err) {
    console.log("Error connecting to Db", err);
    return;
  }
  console.log("Mysql Connected...");
});

//Generate JWT token
const generateToken = (user) => {
  const payload = {
    user_id: user.user_id,
    user_role_id: user.user_role_id,
    // You can include other user data in the payload as needed
  };

  const secretKey = process.env.secret; // Replace with your actual secret key
  const options = {
    expiresIn: "24h", // Token expiration time, adjust as needed
  };

  return jwt.sign(payload, secretKey, options);
};


//Authentication the token
const authenticateToken = (req, res, next) => {
  let token;
  console.log(req.headers.authorization);
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith("Bearer")
  ) {
    token = req.headers.authorization.split(" ")[1];
  }
  if (!token) {
    return res.status(401).json({ message: "You are not authorized" });
  }
  jwt.verify(token, process.env.secret, (err, decoded) => {
    if (err) {
      console.log(err);
      return res.status(401).json({ message: "You are not authorized" });
    }
    req.user = decoded;
    console.log(req.user); // Print the user
    next();
  });
};



//Register
app.post("/register", async (req, res) => {
    const { user_email, user_name, user_password } = req.body;
  
    try {
      connection.query(
        "SELECT * FROM users WHERE user_email = ?",
        [user_email],
        (err, result, fields) => {
          if (err) {
            console.log("Error in the query", err);
            return res.status(400).send();
          }
          if (result.length > 0) {
            return res.status(409).json({ message: "Email already exists" });
          } else {
            bcrypt.hash(user_password, 10, (err, hashedPassword) => {
              if (err) {
                console.log("Error in bcrypt", err);
                return res.status(500).send();
              }
              connection.query(
                "INSERT INTO users(user_email, user_fullname, user_password) VALUES(?,?,?)",
                [user_email, user_name, hashedPassword],
                (err, result, fields) => {
                  if (err) {
                    console.log("Error in the query", err);
                    return res.status(400).send();
                  }
                  return res
                    .status(201)
                    .json({ message: "New user created successfully" });
                }
              );
            });
          }
        }
      );
    } catch (err) {
      console.log(err);
      return res.status(500).send();
    }
  });
  

//Login
app.post("/login", async (req, res) => {
    const { user_email, user_password } = req.body;
  
    try {
      connection.query(
        "SELECT * FROM users WHERE user_email = ?",
        [user_email],
        (err, result, fields) => {
          if (err) {
            console.log("Error in the query", err);
            return res.status(400).send();
          }
          if (result.length === 0) {
            return res.status(400).json({ message: "User not found" });
          }
          const user = result[0];
          bcrypt.compare(user_password, user.user_password, (err, isMatch) => {
            if (err) {
              console.log("Error in bcrypt compare", err);
              return res.status(500).send();
            }
            if (!isMatch) {
              return res.status(400).json({ message: "Invalid password" });
            }
            // Generate JWT token
            // Replace generateToken with your own token generation logic
            const token = generateToken(user);
  
            res.status(200).json({ token }); // Send token as JSON response
          });
        }
      );
    } catch (err) {
      console.log(err);
      res.status(500).send();
    }
  });

//Get User Info from token
app.get("/user", authenticateToken, async (req, res) => {
    console.log(req.user); //decoded is the payload
    try {
      connection.query(
        `SELECT user_id,user_email,user_fullname,user_role_id FROM users  WHERE user_id = '${req.user.user_id}'`,
        (err, result, fields) => {
          if (err) {
            console.log("Error in the query", err);
            return res.status(400).send();
          }
          res.status(200).json(result);
        }
      );
    } catch (err) {
      console.log(err);
      res.status(500).send();
    }
  });

// Join group
app.post("/project/:project_id/join", authenticateToken, async (req, res) => {
    const { project_id } = req.params; // Use 'project_id' instead of 'id'
    try {
      console.log("User id:", req.user.user_id);
  
      connection.query(
        `SELECT * FROM user_project WHERE user_project_user_id = ${req.user.user_id} AND user_project_group_id = ${project_id}`,
        (err, result, fields) => {
          if (err) {
            console.log("Error in the query", err);
            return res.status(400).send();
          }
          if (result.length > 0) {
            // User has already joined the group
            return res.status(400).send("User has already joined the group");
          } else {
            // User has not joined the group, proceed with insertion
            connection.query(
              `INSERT INTO user_project (user_project_user_id, user_project_group_id) VALUES (${req.user.user_id}, ${project_id})`, // Use 'groupid' instead of 'group_id'
              (err, result, fields) => {
                if (err) {
                  console.log("Error in the query", err);
                  return res.status(400).send();
                }
                res.status(200).json(result);
              }
            );
          }
        }
      );
    } catch (err) {
      console.log(err);
      res.status(500).send();
    }
  });

//Check user in the group
app.get("/project/:project_id/join/check", authenticateToken, async (req, res) => {
    const { project_id } = req.params; // Use 'groupid' instead of 'group_id'
    try {
      connection.query(
        `SELECT * FROM user_project WHERE user_project_user_id = ${req.user.user_id} AND user_project_group_id = ${project_id}`,
        (err, result, fields) => {
          if (err) {
            console.log("Error in the query", err);
            return res.status(400).send();
          }
  
          if (result.length > 0) {
            // User has already joined the group
            return res.status(200).send(true);
          } else {
            // User has not joined the group, proceed with insertion
            return res.status(200).send(false);
          }
        }
      );
    } catch (err) {
      console.log(err);
      res.status(500).send();
    }
  });


//Delete user from the group
app.delete("/project/:project_id/join", authenticateToken, async (req, res) => {
    const { project_id } = req.params; // Use 'groupid' instead of 'group_id'
    try {
      connection.query(
        `DELETE FROM user_project WHERE user_project_user_id = ${req.user.user_id} AND user_project_group_id = ${project_id}`,
        (err, result, fields) => {
          if (err) {
            console.log("Error in the query", err);
            return res.status(400).send();
          }
          res.status(200).json(result);
        }
      );
    } catch (err) {
      console.log(err);
      res.status(500).send();
    }
  });

  //Create project
  app.post("/project", authenticateToken, async (req, res) => {
    const { project_name, project_time,project_year,project_address,project_province,project_district,project_subdistrict,project_start_date,project_end_date,project_status,project_lat,project_lon } = req.body;
    if(req.user.user_role_id !== 3){
        return res.status(401).json({ message: "You are not authorized" });
        }
        else{
    try {
        connection.query(
            'INSERT INTO project (project_name, project_time, project_year, project_address, project_province, project_district, project_subdistrict, project_start_date, project_status, project_lat, project_lon) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [project_name, project_time, project_year, project_address, project_province, project_district, project_subdistrict, project_start_date,project_end_date, project_status, project_lat, project_lon],
             // Use 'groupid' instead of 'group_id'
            (err, result, fields) => {
              if (err) {
                console.log("Error in the query", err);
                return res.status(400).send();
              }
              res.status(200).json(result);
            });

    }catch (err) {
        console.log(err);
        res.status(500).send();
      }
    }
        }

  );

  //Get project list
  app.get("/project", authenticateToken, async (req, res) => {
    try {
      connection.query(
        `SELECT * FROM project`,
        (err, result, fields) => {
          if (err) {
            console.log("Error in the query", err);
            return res.status(400).send();
          }
          res.status(200).json(result);
        }
      );
    } catch (err) {
      console.log(err);
      res.status(500).send();
    }
  });
  



  //Get member in the project
  app.get("/project/:project_id/member", authenticateToken, async (req, res) => {
    const { project_id } = req.params; // Use 'groupid' instead of 'group_id'
    try {
      connection.query(
        `SELECT user_id,user_email,user_fullname,user_role_id FROM users INNER JOIN user_project ON users.user_id = user_project.user_project_user_id WHERE user_project_group_id = ${project_id}`,
        (err, result, fields) => {
          if (err) {
            console.log("Error in the query", err);
            return res.status(400).send();
          }
  
          res.status(200).json(result);
        }
      );
    } catch (err) {
      console.log(err);
      res.status(500).send();
    }
  });

  // Get list project that user join
  app.get("/project/join", authenticateToken, async (req, res) => {
    try {
      connection.query(
        `SELECT * FROM project INNER JOIN user_project ON project.project_id = user_project.user_project_group_id WHERE user_project_user_id = ${req.user.user_id}`,
        (err, result, fields) => {
          if (err) {
            console.log("Error in the query", err);
            return res.status(400).send();
          }
          if (result.length === 0) {
            return res.status(200).send();
          }
          res.status(200).json(result);
        }
      );
    } catch (err) {
      console.log(err);
      res.status(500).send();
    }
  });

  //Get all patient
  app.get("/patient", authenticateToken, async (req, res) => {
    try {
      connection.query(
        `SELECT * FROM patient`,
        (err, result, fields) => {
          if (err) {
            console.log("Error in the query", err);
            return res.status(400).send();
          }
          res.status(200).json(result);
        }
      );
    } catch (err) {
      console.log(err);
      res.status(500).send();
    }
  });

  //Get patient by id
  app.get("/patient/:patient_id", authenticateToken, async (req, res) => {
    const { patient_id } = req.params; // Use 'groupid' instead of 'group_id'
    try {
      connection.query(
        `SELECT * FROM patient WHERE patient_id = ${patient_id}`,
        (err, result, fields) => {
          if (err) {
            console.log("Error in the query", err);
            return res.status(400).send();
          }

          res.status(200).json(result);
        }
      );
    } catch (err) {
      console.log(err);
      res.status(500).send();
    }
  });

//Get patient by project id
app.get("/patient/:project_id/project", authenticateToken, async (req, res) => {
  const { project_id } = req.params; 
  try {
    if (req.user.user_role_id === 1 || req.user.user_role_id === 4) {
      return res.status(403).json({ error: "Unauthorized access" });
    }

    connection.query(
      `SELECT patient_id ,patient_name,patient_surname,patient_nationalid,patient_birthday,patient_age FROM patient INNER JOIN patient_project ON patient.patient_id = patient_project.patient_project_patient_id WHERE patient_project_project_id = ${project_id}`,
      (err, result, fields) => {
        if (err) {
          console.log("Error in the query", err);
          return res.status(400).send();
        }

        res.status(200).json(result);
      }
    );
  } catch (err) {
    console.log(err);
    res.status(500).send(); 
  }
});
  
//Get lat lon by project id
app.get("/project/:project_id/latlon", authenticateToken, async (req, res) => {
  const { project_id } = req.params;
  try {
    connection.query(
      `SELECT project_lat,project_lon FROM project WHERE project_id = ${project_id}`,
      (err, result, fields) => {
        if (err) {
          console.log("Error in the query", err);
          return res.status(400).send();
        }

        res.status(200).json(result);
      }
    );
  } catch (err) {
    console.log(err);
    res.status(500).send();
  }
})

//get 5 project that almost time and status is not complete
app.get("/project/almost", authenticateToken, async (req, res) => {
  try {
    connection.query(
      `SELECT * FROM project WHERE project_status != 1 ORDER BY project_start_date ASC LIMIT 3`,
      (err, result, fields) => {
        if (err) {
          console.log("Error in the query", err);
          return res.status(400).send();
        }
        res.status(200).json(result);
      }
    );
  } catch (err) {
    console.log(err);
    res.status(500).send();
  }
}
);

//get project by start date
app.get("/project/startdate", authenticateToken, async (req, res) => {
  try {
    connection.query(
      `SELECT * FROM project WHERE project_status != 1 ORDER BY project_start_date ASC LIMIT 3`,
      (err, result, fields) => {
        if (err) {
          console.log("Error in the query", err);
          return res.status(400).send();
        }
        res.status(200).json(result);
      }
    );
  } catch (err) {
    console.log(err);
    res.status(500).send();
  }
}
);


 

















  app.listen("3000", () => {
    console.log("Server started on port 3000");
  });