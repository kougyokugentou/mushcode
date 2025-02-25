# NOTE: Do not do this while people are playing.
# AND MAKE A BACKUP FIRST!

# Step 1

The following SQL script should be run to update the schema and migrate data.

```sql
BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS vol_actrole (
   actrole_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
   actor_id INT UNSIGNED NOT NULL,
   actrole_name VARCHAR(255) NOT NULL,
   UNIQUE(actor_id,actrole_name),
   FOREIGN KEY (actor_id) REFERENCES vol_actor(actor_id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO vol_actrole (actor_id,actrole_name) SELECT actor_id,character_name FROM volv_actor;

ALTER TABLE vol_action ADD COLUMN actrole_id INT UNSIGNED NULL;

UPDATE vol_action AS a JOIN vol_actrole AS r ON a.actor_id = r.actor_id SET a.actrole_id = r.actrole_id;

ALTER TABLE vol_action DROP FOREIGN KEY vol_action_ibfk_1;
ALTER TABLE vol_action DROP COLUMN actor_id;
ALTER TABLE vol_action DROP COLUMN action_type;
ALTER TABLE vol_action MODIFY actrole_id INT UNSIGNED NOT NULL;

ALTER TABLE vol_action ADD CONSTRAINT fk_vol_action_actrole FOREIGN KEY (actrole_id) REFERENCES vol_actrole(actrole_id) ON UPDATE CASCADE ON DELETE CASCADE;

COMMIT;
```

Then re-run the contents of `schema.sql` to rebuild views and stored procedures.

# Step 2
Re-install the `Scene System - SCENE.txt` file and type `@restart [u(cobj,scene)]` to reload the scene system.