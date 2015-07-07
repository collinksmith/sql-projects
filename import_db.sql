DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);


DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id        INTEGER PRIMARY KEY,
  title     VARCHAR(255) NOT NULL,
  body      TEXT NOT NULL,
  user_id   INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);


DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id          INTEGER PRIMARY KEY,
  user_id     INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id          INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id   INTEGER,
  user_id     INTEGER NOT NULL,
  body        TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id          INTEGER PRIMARY KEY,
  user_id     INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ('Ned', 'Ruggeri'), ('Kush', 'Patel'), ('Eric', 'Schwarzenbach');

INSERT INTO
  questions(title, body, user_id)
VALUES
  ('Good job today?', 'Nice work students, you rock', 1),
  ('Party?', 'Party at my house this friday!!?!?!', 3);

INSERT INTO
  replies(question_id, parent_id, user_id, body)
VALUES
  (2, NULL, 2, 'No parties on my watch. Get back to work'),
  (2, 1, 3, 'Boooo Kush'),
  (1, NULL, 1, 'I am nice?');

INSERT INTO
  question_likes(user_id, question_id)
VALUES
  (1, 1), (1, 2), (3, 1);

INSERT INTO
  question_follows(user_id, question_id)
VALUES
  (1, 2), (3, 2);
