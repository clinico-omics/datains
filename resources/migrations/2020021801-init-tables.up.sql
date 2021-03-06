-- how to run multiple statements in the migrations?
-- See https://github.com/yogthos/migratus#multiple-statements for more details
CREATE TABLE IF NOT EXISTS datains_choppy_app (
  id VARCHAR(32) PRIMARY KEY,
  title VARCHAR(255),
  icon TEXT,
  cover TEXT,
  description TEXT,
  repo_url TEXT,
  author VARCHAR(255),
  rate VARCHAR(16),
  valid BOOLEAN
);

--;;
COMMENT ON TABLE datains_choppy_app IS 'Used for Choppy pipe.';

--;;
CREATE TABLE IF NOT EXISTS datains_project (
  id VARCHAR(36) PRIMARY KEY,
  project_name VARCHAR(64) UNIQUE,
  description TEXT,
  app_id VARCHAR(32) NOT NULL,
  app_name VARCHAR(255) NOT NULL,
  author VARCHAR(32) NOT NULL,
  group_name VARCHAR(32),
  started_time BIGINT NOT NULL,
  finished_time BIGINT,
  samples JSON NOT NULL,
  percentage REAL NOT NULL,
  status VARCHAR(32) NOT NULL
);

--;;
COMMENT ON TABLE datains_project IS 'Used for organizing jobs.';

--;;
COMMENT ON COLUMN datains_project.status IS 'One of Aborted,Aborting,Failed,On Hold,Running,Submitted,Succeeded.';

--;;
COMMENT ON COLUMN datains_project.samples IS 'samples file as json string';

--;;
CREATE TABLE IF NOT EXISTS datains_workflow (
  id VARCHAR(36) PRIMARY KEY,
  workflow_id VARCHAR(36),
  project_id VARCHAR(36) NOT NULL,
  sample_id VARCHAR(64) NOT NULL,
  submitted_time BIGINT NOT NULL,
  started_time BIGINT NOT NULL,
  finished_time BIGINT,
  job_params JSON NOT NULL,
  labels JSON NOT NULL,
  percentage REAL NOT NULL,
  status VARCHAR(32) NOT NULL
);

--;;
COMMENT ON TABLE datains_workflow IS 'Used for recording job details.';

--;;
COMMENT ON COLUMN datains_workflow.job_params IS 'Job parameters for WDL inputs file.';

--;;
COMMENT ON COLUMN datains_workflow.labels IS 'A string seperated by comma.';

--;;
COMMENT ON COLUMN datains_workflow.status IS 'One of Aborted,Aborting,Failed,On Hold,Running,Submitted,Succeeded.';

--;;
CREATE TABLE IF NOT EXISTS datains_report (
  id VARCHAR(36) PRIMARY KEY,
  report_name VARCHAR(64) NOT NULL UNIQUE,
  project_id VARCHAR(36),
  script TEXT,
  description TEXT,
  started_time BIGINT NOT NULL,
  finished_time BIGINT,
  checked_time BIGINT,
  archived_time BIGINT,
  report_path VARCHAR(255),
  report_type VARCHAR(32) NOT NULL,
  status VARCHAR(32) NOT NULL,
  log TEXT
);

--;;
COMMENT ON TABLE datains_report IS 'Used for report.';

--;;
COMMENT ON COLUMN datains_report.id IS 'uuid for report';

--;;
COMMENT ON COLUMN datains_report.script IS 'Auto generated script for making a report';

--;;
COMMENT ON COLUMN datains_report.report_path IS 'A relative path of a report based on the report directory';

--;;
COMMENT ON COLUMN datains_report.report_type IS 'multiqc';

--;;
COMMENT ON COLUMN datains_report.status IS 'Started, Finished, Submitted, Archived, Failed';

--;;
CREATE TABLE IF NOT EXISTS datains_notification (
  id SERIAL NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  notification_type VARCHAR(32) NOT NULL,
  created_time BIGINT NOT NULL,
  status VARCHAR(32) NOT NULL
);

--;;
COMMENT ON TABLE datains_notification IS 'Used for managing notification.';

--;;
COMMENT ON COLUMN datains_notification.id IS 'serial id for report.';

--;;
COMMENT ON COLUMN datains_notification.title IS 'The title of notification.';

--;;
COMMENT ON COLUMN datains_notification.description IS 'A description of notification.';

--;;
COMMENT ON COLUMN datains_notification.notification_type IS 'Which type the notification is.';

--;;
COMMENT ON COLUMN datains_notification.status IS 'Read, Unread';

--;;
CREATE TABLE IF NOT EXISTS datains_log (
  id SERIAL NOT NULL,
  title VARCHAR(255) NOT NULL,
  content TEXT,
  created_time BIGINT NOT NULL,
  log_type VARCHAR(32) NOT NULL,
  entity_id VARCHAR(36) NOT NULL,
  entity_type VARCHAR(32) NOT NULL
);

--;;
COMMENT ON TABLE datains_log IS 'Used for managing logs.';

--;;
COMMENT ON COLUMN datains_log.id IS 'serial id for log.';

--;;
COMMENT ON COLUMN datains_log.title IS 'The title of log.';

--;;
COMMENT ON COLUMN datains_log.content IS 'A content of log, may be a link or content.';

--;;
COMMENT ON COLUMN datains_log.log_type IS 'Which type the log is, Link or Content.';

--;;
COMMENT ON COLUMN datains_log.entity_id IS 'which entity the log is from?';

--;;
COMMENT ON COLUMN datains_log.entity_type IS 'which entity type the log is from?';

--;;
CREATE TABLE IF NOT EXISTS datains_tag (
  id SERIAL NOT NULL,
  title VARCHAR(32) NOT NULL UNIQUE,
  PRIMARY KEY(id)
);

--;;
COMMENT ON TABLE datains_tag IS 'Used for tagging project/app/report etc.';

--;;
CREATE TABLE IF NOT EXISTS datains_entity_tag (
  id SERIAL NOT NULL,
  -- entity_id may contains choppy_app id, project id and report id etc.
  entity_id VARCHAR(32),
  entity_type VARCHAR(32),
  tag_id INT,
  PRIMARY KEY(id),
  CONSTRAINT fk_tag_id FOREIGN KEY (tag_id) REFERENCES datains_tag(id)
);

--;;
COMMENT ON TABLE datains_entity_tag IS 'Used for connecting other entity and tag table.';

--;;
CREATE TABLE qrtz_job_details (
  sched_name VARCHAR(120) NOT NULL,
  job_name VARCHAR(200) NOT NULL,
  job_group VARCHAR(200) NOT NULL,
  description VARCHAR(250),
  job_class_name VARCHAR(250) NOT NULL,
  is_durable BOOLEAN NOT NULL,
  is_nonconcurrent BOOLEAN NOT NULL,
  is_update_data BOOLEAN NOT NULL,
  requests_recovery BOOLEAN NOT NULL,
  job_data BYTEA,
  CONSTRAINT pk_qrtz_job_details PRIMARY KEY (sched_name, job_name, job_group)
) WITH (FILLFACTOR = 100, OIDS = FALSE);

--;;
COMMENT ON TABLE qrtz_job_details IS 'Used for Quartz scheduler.';

--;;
CREATE TABLE qrtz_triggers (
  sched_name VARCHAR(120) NOT NULL,
  trigger_name VARCHAR(200) NOT NULL,
  trigger_group VARCHAR(200) NOT NULL,
  job_name VARCHAR(200) NOT NULL,
  job_group VARCHAR(200) NOT NULL,
  description VARCHAR(250),
  next_fire_time BIGINT,
  prev_fire_time BIGINT,
  priority INTEGER,
  trigger_state VARCHAR(16) NOT NULL,
  trigger_type VARCHAR(8) NOT NULL,
  start_time BIGINT NOT NULL,
  end_time BIGINT,
  calendar_name VARCHAR(200),
  misfire_instr SMALLINT,
  job_data BYTEA,
  CONSTRAINT pk_qrtz_triggers PRIMARY KEY (sched_name, trigger_name, trigger_group),
  CONSTRAINT fk_qrtz_triggers_job_details FOREIGN KEY (sched_name, job_name, job_group) REFERENCES qrtz_job_details(sched_name, job_name, job_group) ON UPDATE NO ACTION ON DELETE NO ACTION NOT VALID
) WITH (FILLFACTOR = 100, OIDS = FALSE);

--;;
COMMENT ON TABLE qrtz_triggers IS 'Used for Quartz scheduler.';

--;;
CREATE TABLE qrtz_calendars (
  sched_name VARCHAR(120) NOT NULL,
  calendar_name VARCHAR(200) NOT NULL,
  calendar BYTEA NOT NULL,
  CONSTRAINT pk_qrtz_calendars PRIMARY KEY (sched_name, calendar_name)
) WITH (FILLFACTOR = 100, OIDS = FALSE);

--;;
COMMENT ON TABLE qrtz_calendars IS 'Used for Quartz scheduler.';

--;;
CREATE TABLE qrtz_cron_triggers (
  sched_name VARCHAR(120) NOT NULL,
  trigger_name VARCHAR(200) NOT NULL,
  trigger_group VARCHAR(200) NOT NULL,
  cron_expression VARCHAR(120) NOT NULL,
  time_zone_id VARCHAR(80),
  CONSTRAINT pk_qrtz_cron_triggers PRIMARY KEY (sched_name, trigger_name, trigger_group),
  CONSTRAINT fk_qrtz_cron_triggers_triggers FOREIGN KEY (sched_name, trigger_name, trigger_group) REFERENCES qrtz_triggers(sched_name, trigger_name, trigger_group) ON UPDATE NO ACTION ON DELETE NO ACTION NOT VALID
) WITH (FILLFACTOR = 100, OIDS = FALSE);

--;;
COMMENT ON TABLE qrtz_cron_triggers IS 'Used for Quartz scheduler.';

--;;
CREATE TABLE qrtz_fired_triggers (
  sched_name VARCHAR(120) NOT NULL,
  entry_id VARCHAR(95) NOT NULL,
  trigger_name VARCHAR(200) NOT NULL,
  trigger_group VARCHAR(200) NOT NULL,
  instance_name VARCHAR(200) NOT NULL,
  fired_time BIGINT NOT NULL,
  sched_time BIGINT,
  priority INTEGER NOT NULL,
  state VARCHAR(16) NOT NULL,
  job_name VARCHAR(200),
  job_group VARCHAR(200),
  is_nonconcurrent BOOLEAN,
  requests_recovery BOOLEAN,
  CONSTRAINT pk_qrtz_fired_triggers PRIMARY KEY (sched_name, entry_id)
) WITH (FILLFACTOR = 100, OIDS = FALSE);

--;;
COMMENT ON TABLE qrtz_fired_triggers IS 'Used for Quartz scheduler.';

--;;
CREATE TABLE qrtz_locks (
  sched_name VARCHAR(120) NOT NULL,
  lock_name VARCHAR(40) NOT NULL,
  CONSTRAINT pk_qrtz_locks PRIMARY KEY (sched_name, lock_name)
) WITH (FILLFACTOR = 100, OIDS = FALSE);

--;;
COMMENT ON TABLE qrtz_locks IS 'Used for Quartz scheduler.';

--;;
CREATE TABLE qrtz_paused_trigger_grps (
  sched_name VARCHAR(120) NOT NULL,
  trigger_group VARCHAR(200) NOT NULL,
  CONSTRAINT pk_qrtz_paused_trigger_grps PRIMARY KEY (sched_name, trigger_group)
) WITH (FILLFACTOR = 100, OIDS = FALSE);

--;;
COMMENT ON TABLE qrtz_paused_trigger_grps IS 'Used for Quartz scheduler.';

--;;
CREATE TABLE qrtz_scheduler_state (
  sched_name VARCHAR(120) NOT NULL,
  instance_name VARCHAR(200) NOT NULL,
  last_checkin_time BIGINT NOT NULL,
  checkin_interval BIGINT NOT NULL,
  CONSTRAINT pk_qrtz_scheduler_state PRIMARY KEY (sched_name, instance_name)
) WITH (FILLFACTOR = 100, OIDS = FALSE);

--;;
COMMENT ON TABLE qrtz_scheduler_state IS 'Used for Quartz scheduler.';

--;;
CREATE TABLE qrtz_simple_triggers (
  sched_name VARCHAR(120) NOT NULL,
  trigger_name VARCHAR(200) NOT NULL,
  trigger_group VARCHAR(200) NOT NULL,
  repeat_count BIGINT NOT NULL,
  repeat_interval BIGINT NOT NULL,
  times_triggered BIGINT NOT NULL,
  CONSTRAINT pk_qrtz_simple_triggers PRIMARY KEY (sched_name, trigger_name, trigger_group),
  CONSTRAINT fk_qrtz_simple_triggers_triggers FOREIGN KEY (sched_name, trigger_name, trigger_group) REFERENCES qrtz_triggers(sched_name, trigger_name, trigger_group) ON UPDATE NO ACTION ON DELETE NO ACTION NOT VALID
) WITH (FILLFACTOR = 100, OIDS = FALSE);

--;;
COMMENT ON TABLE qrtz_simple_triggers IS 'Used for Quartz scheduler.';

--;;
CREATE TABLE qrtz_simprop_triggers (
  sched_name VARCHAR(120) NOT NULL,
  trigger_name VARCHAR(200) NOT NULL,
  trigger_group VARCHAR(200) NOT NULL,
  str_prop_1 VARCHAR(512),
  str_prop_2 VARCHAR(512),
  str_prop_3 VARCHAR(512),
  int_prop_1 INTEGER,
  int_prop_2 INTEGER,
  long_prop_1 BIGINT,
  long_prop_2 BIGINT,
  dec_prop_1 NUMERIC(13, 4),
  dec_prop_2 NUMERIC(13, 4),
  bool_prop_1 BOOLEAN,
  bool_prop_2 BOOLEAN,
  CONSTRAINT pk_qrtz_simprop_triggers PRIMARY KEY (sched_name, trigger_name, trigger_group),
  CONSTRAINT fk_qrtz_simprop_triggers_triggers FOREIGN KEY (sched_name, trigger_name, trigger_group) REFERENCES qrtz_triggers(sched_name, trigger_name, trigger_group) ON UPDATE NO ACTION ON DELETE NO ACTION NOT VALID
) WITH (FILLFACTOR = 100, OIDS = FALSE);

--;;
COMMENT ON TABLE qrtz_simprop_triggers IS 'Used for Quartz scheduler.';

--;;
CREATE TABLE IF NOT EXISTS qrtz_blob_triggers (
  sched_name VARCHAR(120) NOT NULL,
  trigger_name VARCHAR(200) NOT NULL,
  trigger_group VARCHAR(200) NOT NULL,
  blob_data BYTEA,
  CONSTRAINT pk_qrtz_blob_triggers PRIMARY KEY (sched_name, trigger_name, trigger_group),
  CONSTRAINT fk_qrtz_blob_triggers_triggers FOREIGN KEY (sched_name, trigger_name, trigger_group) REFERENCES qrtz_triggers(sched_name, trigger_name, trigger_group) ON UPDATE NO ACTION ON DELETE NO ACTION NOT VALID
) WITH (FILLFACTOR = 100, OIDS = FALSE);

--;;
COMMENT ON TABLE qrtz_blob_triggers IS 'Used for Quartz scheduler.';

--;;