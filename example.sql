CREATE KEYSPACE IF NOT EXISTS testkeyspace
  WITH replication = { 'class': 'SimpleStrategy', 'replication_factor': '1'};

use testkeyspace;

CREATE TABLE IF NOT EXISTS users (
  name text,
  age int,
  active boolean,
  PRIMARY KEY (name)
);

create index users_active_idx on users(active);

copy users (name, age, active) from 'example-input';
