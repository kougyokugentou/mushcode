CREATE TABLE IF NOT EXISTS vol_story_templates (
	template_id TINYINT UNSIGNED NOT NULL,
	template_name VARCHAR(18) NOT NULL UNIQUE,
	template_playable TINYINT UNSIGNED NOT NULL DEFAULT 1,
	template_power_stat_name VARCHAR(15) NULL,
	template_desc text NULL DEFAULT NULL,
	PRIMARY KEY(template_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

CREATE TABLE IF NOT EXISTS vol_story_templates_statlimits (
    limit_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    template_id INT UNSIGNED NOT NULL,
    stat_id INT UNSIGNED NOT NULL,
    limit_mode TINYINT UNSIGNED NOT NULL,
    limit_value TINYINT UNSIGNED NOT NULL,
    limit_pip TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY(limit_id),
    FOREIGN KEY(template_id) REFERENCES vol_story_templates(template_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY(stat_id) REFERENCES vol_story_stats(stat_id) ON UPDATE CASCADE ON DELETE CASCADE,
    UNIQUE(template_id,stat_id,limit_mode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

CREATE TABLE IF NOT EXISTS vol_story_templates_info (
    info_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    template_id INT UNSIGNED NOT NULL,
    info_name VARCHAR(255) NOT NULL,
    info_desc TEXT NOT NULL,
    PRIMARY KEY(info_id),
    FOREIGN KEY(template_id) REFERENCES vol_story_templates(template_id) ON UPDATE CASCADE ON DELETE CASCADE,
    UNIQUE(template_id,info_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

CREATE TABLE IF NOT EXISTS vol_story_template_sub (
	template_sub_id INT UNSIGNED NOT NULL,
	template_id TINYINT UNSIGNED NOT NULL,
	template_sub_name VARCHAR(80) NOT NULL,
	template_sub_slot TINYINT UNSIGNED NULL,
	PRIMARY KEY(template_sub_id),
	FOREIGN KEY(template_id) REFERENCES vol_story_templates(template_id) ON UPDATE CASCADE ON DELETE CASCADE,
	UNIQUE(template_id,template_sub_name),
	UNIQUE(template_id,template_sub_slot)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

CREATE OR REPLACE VIEW volv_story_template_sub AS
	SELECT t.template_id AS template_id,t.template_name AS template_name,t.template_playable AS template_playable,s.template_sub_id AS template_sub_id,s.template_sub_name AS template_sub_name,s.template_sub_slot AS template_sub_slot FROM vol_story_template_sub AS s LEFT JOIN vol_story_templates AS t ON s.template_id=t.template_id ORDER BY t.template_name DESC,s.template_sub_name DESC;

CREATE TABLE IF NOT EXISTS vol_story_template_sub_choices (
	template_sub_choice_id INT UNSIGNED NOT NULL,
	template_sub_id INT UNSIGNED NOT NULL,
	template_sub_choice_name VARCHAR(80) NOT NULL,
	PRIMARY KEY(template_sub_choice_id),
	FOREIGN KEY(template_sub_id) REFERENCES vol_story_template_sub(template_sub_id) ON UPDATE CASCADE ON DELETE CASCADE,
	UNIQUE(template_sub_id,template_sub_choice_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

CREATE OR REPLACE VIEW volv_story_template_sub_choices AS
	SELECT t.template_id AS template_id,t.template_name AS template_name,t.template_playable AS template_playable,t.template_sub_id AS template_sub_id,t.template_sub_name AS template_sub_name,t.template_sub_slot AS template_sub_slot,c.template_sub_choice_id AS template_sub_choice_id,c.template_sub_choice_name AS template_sub_choice_name FROM vol_story_template_sub_choices AS c LEFT JOIN volv_story_template_sub AS t ON c.template_sub_id=t.template_sub_id ORDER BY t.template_name DESC,t.template_sub_name DESC,c.template_sub_choice_name DESC;

/*
Template ID 0 reserved for universal logic.
Template Ids over 100 are reserved for System use. They arent Playable Templates.
*/

CREATE TABLE IF NOT EXISTS vol_story_personas (
	persona_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
	owner_id INT UNSIGNED NOT NULL,
	persona_name VARCHAR(80) NOT NULL,
	template_id TINYINT UNSIGNED NOT NULL DEFAULT 1,
	persona_parent INT UNSIGNED NULL,
	power_stat_value TINYINT UNSIGNED NOT NULL DEFAULT 1,
	persona_date_created DATETIME NOT NULL,
	approval_id INT UNSIGNED NULL,
	PRIMARY KEY(persona_id),
	FOREIGN KEY(owner_id) REFERENCES vol_entity(entity_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(template_id) REFERENCES vol_story_templates(template_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(persona_parent) REFERENCES vol_story_personas(persona_id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS vol_story_personas_approval (
    approval_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    persona_id INT UNSIGNED NOT NULL,
    admin_id INT UNSIGNED NOT NULL,
    approval_state TINYINT UNSIGNED NOT NULL,
    approval_date DATETIME NOT NULL,
    approval_notes TEXT NULL,
    PRIMARY KEY(approval_id),
    FOREIGN KEY(persona_id) REFERENCES vol_story_personas(persona_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY(admin_id) REFERENCES vol_entity(entity_id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci AUTO_INCREMENT=1;

CREATE OR REPLACE VIEW volv_story_personas_approval AS
    SELECT a.approval_id AS approval_id,a.persona_id AS persona_id,a.admin_id AS admin_id,e.entity_name AS admin_name,a.approval_state AS approval_state,a.approval_date AS approval_date,UNIX_TIMESTAMP(a.approval_date) AS approval_date_secs,a.approval_notes AS approval_notes FROM vol_story_personas_approval AS a LEFT JOIN vol_entity AS e ON a.admin_id=e.entity_id;

CREATE OR REPLACE VIEW volv_story_personas AS
    SELECT p.persona_id AS persona_id,p.owner_id AS owner_id,e.entity_name AS owner_name,e.entity_objid AS owner_objid,p.template_id AS template_id,t.template_name AS template_name,p.persona_name AS persona_name,p.persona_parent AS persona_parent,p2.persona_name AS persona_parent_name,t.template_power_stat_name AS template_power_stat_name,p.power_stat_value AS power_stat_value,p.persona_date_created AS persona_date_created,UNIX_TIMESTAMP(p.persona_date_created) AS persona_date_created_secs,p.approval_id AS approval_id,a.admin_id AS admin_id,a.admin_name AS admin_name,a.approval_state AS approval_state,a.approval_date AS approval_date,a.approval_date_secs AS approval_date_secs FROM vol_story_personas AS p LEFT JOIN vol_story_templates AS t ON p.template_id=t.template_id LEFT JOIN vol_entity AS e ON p.owner_id=e.entity_id LEFT JOIN vol_story_personas AS p2 ON p.persona_parent=p2.persona_id LEFT JOIN volv_story_personas_approval AS a ON p.approval_id=a.approval_id;

CREATE TABLE IF NOT EXISTS vol_story_persona_sub_choices (
	persona_id INT UNSIGNED NOT NULL,
	template_sub_choice_id INT UNSIGNED NOT NULL,
	FOREIGN KEY(persona_id) REFERENCES vol_story_personas(persona_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(template_sub_choice_id) REFERENCES vol_story_template_sub_choices(template_sub_choice_id) ON UPDATE CASCADE ON DELETE CASCADE,
	UNIQUE(persona_id,template_sub_choice_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci AUTO_INCREMENT=1;

CREATE OR REPLACE VIEW volv_story_persona_sub_choices AS
    SELECT s.*,p.persona_id AS persona_id FROM vol_story_persona_sub_choices AS p LEFT JOIN vol_story_template_sub_choices AS s ON s.template_sub_choice_id=p.template_sub_choice_id;

CREATE TABLE IF NOT EXISTS vol_story_fields (
	field_id INT UNSIGNED NOT NULL,
	field_name VARCHAR(20) NOT NULL UNIQUE,
	PRIMARY KEY(field_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

CREATE TABLE IF NOT EXISTS vol_story_template_fields (
	tlink_id INT UNSIGNED NOT NULL,
	field_id INT UNSIGNED NOT NULL,
	template_id TINYINT UNSIGNED NOT NULL,
	PRIMARY KEY(tlink_id),
	FOREIGN KEY(field_id) REFERENCES vol_story_fields(field_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(template_id) REFERENCES vol_story_templates(template_id) ON UPDATE CASCADE ON DELETE CASCADE,
	UNIQUE(template_id,field_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci AUTO_INCREMENT=1;

CREATE OR REPLACE VIEW volv_story_template_fields AS
	SELECT tf.tlink_id AS tlink_id,tf.template_id AS template_id,t.template_name AS template_name,tf.field_id AS field_id,f.field_name AS field_name FROM vol_story_template_fields AS tf LEFT JOIN vol_story_templates AS t ON t.template_id=tf.template_id LEFT JOIN vol_story_fields AS f ON tf.field_id=f.field_id ORDER BY f.field_id;
	
CREATE TABLE IF NOT EXISTS vol_story_persona_field (
	persona_id INT UNSIGNED NOT NULL,
	field_id INT UNSIGNED NOT NULL,
	field_answer VARCHAR(40),
	FOREIGN KEY(persona_id) REFERENCES vol_story_personas(persona_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(field_id) REFERENCES vol_story_fields(field_id) ON UPDATE CASCADE ON DELETE CASCADE,
	UNIQUE(persona_id,field_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci AUTO_INCREMENT=1;

CREATE OR REPLACE VIEW volv_story_persona_field AS
	SELECT p.persona_id as persona_id,f.field_id as field_id,f.field_name as field_name,p.field_answer as field_answer FROM vol_story_persona_field AS p LEFT JOIN vol_story_fields AS f ON p.field_id=f.field_id;

CREATE TABLE IF NOT EXISTS vol_story_stats (
	stat_id INT UNSIGNED NOT NULL,
	template_id TINYINT UNSIGNED NOT NULL, /* Use 0 for UNIVERSAL. Do not Foreign key this field. */
	stat_name VARCHAR(80),
	stat_altname VARCHAR(80),
	stat_plural VARCHAR(80),
	stat_custom TINYINT UNSIGNED NOT NULL DEFAULT 0,
	stat_specialties TINYINT UNSIGNED NOT NULL DEFAULT 0,
	stat_allows_zero TINYINT UNSIGNED NOT NULL DEFAULT 0,
	stat_rank INT NOT NULL DEFAULT 0,
	stat_cost INT NOT NULL DEFAULT 0,
	stat_parent INT UNSIGNED NULL,
	stat_require_context TINYINT UNSIGNED NOT NULL DEFAULT 0, 
	stat_can_set TINYINT UNSIGNED NOT NULL DEFAULT 1, /* This is 0 for category-containers */
	stat_minimum TINYINT NOT NULL DEFAULT 0,
	stat_maximum TINYINT NOT NULL DEFAULT 127,
	PRIMARY KEY(stat_id),
	FOREIGN KEY(template_id) REFERENCES vol_story_templates(template_id) ON UPDATE CASCADE ON DELETE CASCADE,
	UNIQUE(template_id,stat_parent,stat_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

CREATE OR REPLACE VIEW volv_story_stats AS
    SELECT s.stat_id as stat_id,s.template_id AS template_id,s.stat_name AS stat_name,s.stat_plural AS stat_plural,s.stat_altname AS stat_altname,s.stat_custom AS stat_custom,s.stat_specialties AS stat_specialties,s.stat_allows_zero AS stat_allows_zero,s.stat_cost AS stat_cost,s.stat_rank AS stat_rank,s.stat_require_context AS stat_require_context,s.stat_can_set,s.stat_minimum as stat_minimum,s.stat_maximum AS stat_maximum,s.stat_parent AS stat_parent,c.stat_name AS parent_name,c.stat_plural AS parent_plural,c.stat_altname AS parent_altname FROM vol_story_stats AS s LEFT JOIN vol_story_stats AS c ON s.stat_parent=c.stat_id;

CREATE TABLE IF NOT EXISTS vol_story_stats_ids (
    stat_id INT UNSIGNED NOT NULL UNIQUE,
    stat_id_minimum INT UNSIGNED NOT NULL,
    stat_id_maximum INT UNSIGNED NOT NULL,
    FOREIGN KEY(stat_id) REFERENCES vol_story_stats(stat_id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci AUTO_INCREMENT=1;

CREATE OR REPLACE VIEW volv_story_stats_ids AS
    SELECT s.*,i.stat_id_minimum,i.stat_id_maximum FROM vol_story_stats_ids AS i LEFT JOIN volv_story_stats AS s ON i.stat_id=s.stat_id;

CREATE TABLE IF NOT EXISTS vol_story_stat_defaults (
	template_id TINYINT UNSIGNED NOT NULL,
	stat_id INT UNSIGNED NOT NULL,
	stat_value INT NOT NULL DEFAULT 0,
	UNIQUE(template_id,stat_id),
	FOREIGN KEY(stat_id) REFERENCES vol_story_stats(stat_id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS vol_story_persona_stats (
	persona_stat_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
	persona_id INT UNSIGNED NOT NULL,
	persona_stat_type TINYINT UNSIGNED NOT NULL DEFAULT 0,
	stat_id INT UNSIGNED NULL,
	persona_stat_name VARCHAR(80) NOT NULL DEFAULT '',
	stat_value INT NOT NULL DEFAULT 0,
	stat_flags_1 TINYINT UNSIGNED NOT NULL DEFAULT 0,
	stat_flags_2 TINYINT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY(persona_stat_id),
	FOREIGN KEY(persona_id) REFERENCES vol_story_personas(persona_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(stat_id) REFERENCES vol_story_stats(stat_id) ON UPDATE CASCADE ON DELETE CASCADE,
	UNIQUE(persona_id,persona_stat_type,stat_id,persona_stat_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci AUTO_INCREMENT=1;

CREATE OR REPLACE VIEW volv_story_persona_stats AS
    SELECT p.persona_stat_id as persona_stat_id,p.persona_id AS persona_id,p.persona_stat_type AS persona_stat_type,p.persona_stat_name AS persona_stat_name,p.stat_value AS stat_value,p.stat_flags_1 AS stat_flags_1,p.stat_flags_2 AS stat_flags_2,IF(CHAR_LENGTH(p.persona_stat_name),IF(s.stat_specialties,CONCAT_WS('_',s.stat_name,p.persona_stat_name),IF(s.stat_custom,CONCAT_WS('>',s.stat_name,p.persona_stat_name),IF(s.stat_require_context,CONCAT_WS(': ',s.stat_name,p.persona_stat_name),s.stat_name))),s.stat_name) AS display_roll_name,s.* FROM vol_story_persona_stats AS p LEFT JOIN volv_story_stats AS s ON p.stat_id=s.stat_id;

CREATE TABLE IF NOT EXISTS vol_story_persona_stats_extra (
	persona_stat_id INT UNSIGNED NOT NULL,
	persona_stat_extra_type TINYINT UNSIGNED NOT NULL,
	persona_stat_extra_name VARCHAR(80) NOT NULL DEFAULT '',
	persona_stat_extra_description TEXT NULL,
	persona_stat_extra_notes TEXT NULL,
	FOREIGN KEY(persona_stat_id) REFERENCES vol_story_persona_stats(persona_stat_id) ON UPDATE CASCADE ON DELETE CASCADE,
	UNIQUE(persona_stat_id,persona_stat_extra_type,persona_stat_extra_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci AUTO_INCREMENT=1;


CREATE TABLE IF NOT EXISTS vol_story_pools_categories (
	pool_category_id TINYINT UNSIGNED NOT NULL,
	pool_category_name VARCHAR(20) NOT NULL UNIQUE,
	PRIMARY KEY(pool_category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
	
CREATE TABLE IF NOT EXISTS vol_story_pools (
	pool_id TINYINT UNSIGNED NOT NULL,
	pool_category_id TINYINT UNSIGNED NOT NULL,
	pool_name VARCHAR(20) NOT NULL UNIQUE,
	pool_unit_name VARCHAR(20) NOT NULL,
	pool_single_name VARCHAR(20) NOT NULL DEFAULT "Point",
	pool_plural_name VARCHAR(20) NOT NULL DEFAULT "Points",
	pool_sort TINYINT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY(pool_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

CREATE OR REPLACE VIEW volv_story_pools AS
	SELECT p.*,c.pool_category_name FROM vol_story_pools AS p LEFT JOIN vol_story_pools_categories AS c ON p.pool_category_id=c.pool_category_id ORDER BY p.pool_sort;

CREATE TABLE IF NOT EXISTS vol_story_persona_pools (
	persona_pool_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
	persona_id INT UNSIGNED NOT NULL,
	pool_id TINYINT UNSIGNED NOT NULL,
	pool_current INT UNSIGNED NOT NULL DEFAULT 0,
	pool_maximum INT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY(persona_pool_id),
	UNIQUE(persona_id,pool_id),
	FOREIGN KEY(persona_id) REFERENCES vol_story_personas(persona_id) ON UPDATE CASCADE ON DELETE CASCADE
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci AUTO_INCREMENT=1;
	
CREATE TABLE IF NOT EXISTS vol_story_persona_pools_commits (
	persona_commit_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
	persona_pool_id INT UNSIGNED NOT NULL,
	commit_name VARCHAR(255) NOT NULL,
	commit_amount INT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY(persona_commit_id),
	UNIQUE(persona_pool_id,commit_name),
	FOREIGN KEY(persona_pool_id) REFERENCES vol_story_persona_pools(persona_pool_id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci AUTO_INCREMENT=1;

CREATE OR REPLACE VIEW volv_story_persona_pools_commits AS
    SELECT po.*,p.persona_commit_id,p.commit_name,p.commit_amount FROM vol_story_persona_pools_commits AS p LEFT JOIN vol_story_persona_pools AS po ON po.persona_pool_id=p.persona_pool_id;

CREATE TABLE IF NOT EXISTS vol_story_xp (
	xp_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
	xp_name VARCHAR(30) UNIQUE,
	xp_sort TINYINT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY(xp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS vol_story_persona_xp (
	persona_xp_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
	xp_id TINYINT UNSIGNED NOT NULL,
	persona_id INT UNSIGNED NOT NULL,
	xp_amount DECIMAL(7,3),
	admin_id INT UNSIGNED NOT NULL,
	xp_reason TEXT,
	xp_date DATETIME NOT NULL,
	xp_display_num INT UNSIGNED NOT NULL,
	PRIMARY KEY(persona_xp_id),
	FOREIGN KEY(persona_id) REFERENCES vol_story_personas(persona_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(xp_id) REFERENCES vol_story_xp(xp_id) ON UPDATE CASCADE ON DELETE CASCADE,
	UNIQUE(xp_id,persona_id,xp_display_num)	
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci AUTO_INCREMENT=1;

CREATE OR REPLACE VIEW volv_story_persona_xp AS
	SELECT px.*,UNIX_TIMESTAMP(px.xp_date) AS xp_date_secs,p.persona_name,p.owner_name,p.owner_objid,x.xp_name,x.xp_sort,e.entity_name AS admin_name,e.entity_objid AS admin_objid FROM vol_story_persona_xp AS px LEFT JOIN vol_story_xp AS x ON px.xp_id=x.xp_id LEFT JOIN volv_story_personas AS p ON px.persona_id=p.persona_id LEFT JOIN vol_entity AS e ON px.admin_id=e.entity_id ORDER BY x.xp_sort;

CREATE OR REPLACE VIEW volv_story_persona_xp_totals AS
  SELECT x.xp_id,x.xp_name,x.xp_sort,x.persona_id,x.persona_name,x.owner_name,x.owner_objid,MAX(IF(x.xp_display_num,x.xp_display_num,1))+1 AS next_display_num,SUM(IF(x.xp_amount>0,x.xp_amount,0)) AS xp_gained,ABS(SUM(IF(x.xp_amount<0,x.xp_amount,0))) AS xp_spent,SUM(x.xp_amount) AS xp_current
  FROM volv_story_persona_xp AS x
  GROUP BY x.xp_id,x.persona_id ORDER BY x.persona_name,x.xp_sort;
  
DROP PROCEDURE IF EXISTS volp_story_xp;
DELIMITER $$
CREATE PROCEDURE volp_story_xp(IN in_persona_id INT UNSIGNED,IN in_xp_id TINYINT UNSIGNED,IN in_xp_amount DECIMAL(7,3),IN in_xp_reason TEXT,IN in_admin_id INT UNSIGNED)
  BEGIN
    DECLARE next_num INT UNSIGNED;
    DECLARE new_persona_xp_id INT UNSIGNED;
    SELECT next_display_num INTO next_num FROM volv_story_persona_xp_totals WHERE persona_id=in_persona_id AND xp_id=in_xp_id;
    IF next_num IS NULL THEN
      SET next_num=1;
    END IF;
    INSERT INTO vol_story_persona_xp(persona_id,xp_id,xp_display_num,xp_amount,admin_id,xp_reason,xp_date) VALUES (in_persona_id,in_xp_id,next_num,in_xp_amount,in_admin_id,in_xp_reason,UTC_TIMESTAMP());
    SET new_persona_xp_id=LAST_INSERT_ID();
    SELECT new_persona_xp_id;
  END $$
DELIMITER ;

CREATE TABLE IF NOT EXISTS vol_story_rec (
	rec_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
	source_id INT UNSIGNED NOT NULL,
	persona_id INT UNSIGNED NOT NULL,
	xp_id TINYINT UNSIGNED NOT NULL,
	rec_amount DECIMAL(7,3),
	rec_reason TEXT,
	rec_submit_date DATETIME,
	rec_status TINYINT UNSIGNED NOT NULL DEFAULT 0,
	rec_approve_date DATETIME,
	rec_approve_amount DECIMAL(7,3),
	admin_id INT UNSIGNED NULL,
	persona_xp_id INT UNSIGNED NULL,
	PRIMARY KEY(rec_id),
	FOREIGN KEY(source_id) REFERENCES vol_entity(entity_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(admin_id) REFERENCES vol_entity(entity_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(persona_id) REFERENCES vol_story_personas(persona_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(xp_id) REFERENCES vol_story_xp(xp_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(persona_xp_id) REFERENCES vol_story_persona_xp(persona_xp_id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci AUTO_INCREMENT=1;

CREATE OR REPLACE VIEW volv_story_rec AS
	SELECT r.*,UNIX_TIMESTAMP(r.rec_submit_date) AS rec_submit_date_secs,UNIX_TIMESTAMP(r.rec_approve_date) AS rec_approve_date_secs,s.entity_name AS source_name,s.entity_objid AS source_objid,p.persona_name,p.owner_objid,x.xp_name,x.xp_sort,a.entity_name AS admin_name,a.entity_objid AS admin_objid FROM vol_story_rec AS r LEFT JOIN vol_entity AS s ON s.entity_id=r.source_id LEFT JOIN volv_story_personas AS p ON p.persona_id=r.persona_id LEFT JOIN vol_story_xp AS x ON x.xp_id=r.xp_id LEFT JOIN vol_entity AS a ON a.entity_id=r.admin_id;
