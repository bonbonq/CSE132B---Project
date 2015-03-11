DROP TABLE cpqg_table CASCADE;
CREATE TABLE cpqg_table
(
	idcourse integer,
	faculty_name text,
	idquarter integer,
	grade text,
	idcpqg SERIAL
);

INSERT INTO cpqg_table (idcourse, faculty_name, idquarter, grade) 
(SELECT idcourse, faculty_name, idquarter, grade FROM (SELECT DISTINCT faculty_name, idclass FROM faculty_class_section) AS fcs NATURAL JOIN (SELECT * FROM quarter_course_class__instance NATURAL JOIN student_instance) AS yeah NATURAL JOIN quarter);

CREATE VIEW cpqg AS
(SELECT * FROM cpqg_table);

DROP TABLE cpg_table CASCADE;
CREATE TABLE cpg_table
(
	idcourse integer,
	faculty_name text,
	grade text,
	idcpg SERIAL
);

INSERT INTO cpg_table (idcourse, faculty_name, grade) 
(SELECT idcourse, faculty_name, grade FROM (SELECT DISTINCT faculty_name, idclass FROM faculty_class_section) AS fcs NATURAL JOIN (SELECT * FROM quarter_course_class__instance NATURAL JOIN student_instance) AS yeah);

CREATE VIEW cpg AS
(SELECT * FROM cpg_table);

DROP TRIGGER IF EXISTS delete_cpqg ON student_instance;
DROP TRIGGER IF EXISTS delete_cpg ON student_instance;
DROP TRIGGER IF EXISTS insert_cpqg ON student_instance;
DROP TRIGGER IF EXISTS insert_cpg ON student_instance;
DROP TRIGGER IF EXISTS update_cpqg ON student_instance;
DROP TRIGGER IF EXISTS update_cpg ON student_instance;
DROP TRIGGER IF EXISTS enroll_section ON student_section__enrolled;
DROP TRIGGER IF EXISTS insert_update_section_weekly ON section_weekly;
DROP TRIGGER IF EXISTS insert_section_weekly ON section_weekly;
DROP TRIGGER IF EXISTS update_section_weekly ON weekly;
DROP TRIGGER IF EXISTS update_faculty_class_section ON faculty_class_section;
DROP TRIGGER IF EXISTS student_attends_entry ON student_quarter__attends;
DROP FUNCTION IF EXISTS check_conflict();
DROP FUNCTION IF EXISTS check_conflict_update();
DROP FUNCTION IF EXISTS check_section_conflict();
DROP FUNCTION IF EXISTS check_enrollment();
DROP FUNCTION IF EXISTS check_student_attends();
DROP FUNCTION IF EXISTS proc_insert_cpqg();
DROP FUNCTION IF EXISTS proc_insert_cpg();
DROP FUNCTION IF EXISTS proc_delete_cpqg();
DROP FUNCTION IF EXISTS proc_delete_cpg();
DROP FUNCTION IF EXISTS proc_update_cpqg();
DROP FUNCTION IF EXISTS proc_update_cpg();

-------------------------------------------
-- PROCECURE check_conflict
-- Ensures no time conflict occurs within a section
-- Or within a Professor's regular sections
-- USE WITH TRIGGER insert_update_section_weekly
-------------------------------------------
CREATE OR REPLACE FUNCTION check_conflict() RETURNS trigger AS $conflict$
BEGIN

	CREATE TEMPORARY TABLE same_section (
		idweekly integer,
		day_of_week integer,
		start_time TIME,
		end_time TIME
	);

	CREATE TEMPORARY TABLE same_faculty (
		idweekly integer,
		day_of_week integer,
		start_time TIME,
		end_time TIME
	);

	CREATE TEMPORARY TABLE section_of_interest (
		idweekly integer
	);

	CREATE TEMPORARY TABLE faculty_of_interest (
		idweekly integer
	);

	INSERT INTO same_section 
		(SELECT idweekly, day_of_week, start_time, end_time 
			FROM weekly NATURAL JOIN section_weekly 	
			WHERE idsection = NEW.idsection
			AND idweekly <> NEW.idweekly
		);

	INSERT INTO same_faculty
		(SELECT idweekly, day_of_week, start_time, end_time
 			FROM faculty_class_section NATURAL JOIN section_weekly NATURAL JOIN weekly
 			WHERE faculty_name IN 
 						(SELECT faculty_name FROM faculty_class_section NATURAL JOIN section_weekly NATURAL JOIN weekly
 						WHERE faculty_class_section.idsection = NEW.idsection)
 			AND idweekly <> NEW.idweekly);

	INSERT INTO section_of_interest
	(SELECT idweekly FROM weekly AS a 
	WHERE NEW.idweekly = a.idweekly
	AND (
		(0 = ALL (SELECT (a.day_of_week & day_of_week) FROM same_section))
		OR 
		(TRUE = ALL 
			(SELECT (a.end_time < start_time) OR (a.start_time > end_time) FROM same_section)
		)
		)
		);

	INSERT INTO faculty_of_interest
	(SELECT idweekly FROM weekly AS a 
	WHERE NEW.idweekly = a.idweekly
	AND (
	--	(0 = ALL
		--	(SELECT (a.day_of_week & day_of_week) FROM same_faculty))
	--OR 
		(TRUE = ALL
			(SELECT (same_faculty.end_time < a.start_time) OR (same_faculty.start_time > a.end_time)  FROM same_faculty)
		))
	);

	IF (NOT EXISTS (SELECT * FROM section_of_interest)) THEN
		DROP TABLE same_section;
		DROP TABLE same_faculty;
		DROP TABLE section_of_interest;
		DROP TABLE faculty_of_interest;
		RAISE EXCEPTION 'Conflicts with another subsection of this section';

	ELSIF (NOT EXISTS (SELECT * FROM faculty_of_interest)) THEN
		DROP TABLE same_section;
		DROP TABLE same_faculty;
		DROP TABLE section_of_interest;
		DROP TABLE faculty_of_interest;
		RAISE EXCEPTION 'Conflicts with another of facultys sections';

	END IF;
	
	DROP TABLE same_section;
	DROP TABLE same_faculty;
	DROP TABLE section_of_interest;
	DROP TABLE faculty_of_interest;
	RETURN NEW;

END;
$conflict$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_conflict_update() RETURNS trigger AS $conflict_update$
BEGIN

	CREATE TEMPORARY TABLE same_section (
		idweekly integer,
		day_of_week integer,
		start_time TIME,
		end_time TIME
	);

	CREATE TEMPORARY TABLE same_faculty (
		idweekly integer,
		day_of_week integer,
		start_time TIME,
		end_time TIME
	);

	CREATE TEMPORARY TABLE section_of_interest (
		idweekly integer
	);

	CREATE TEMPORARY TABLE faculty_of_interest (
		idweekly integer
	);

	INSERT INTO same_section 
		(SELECT idweekly, day_of_week, start_time, end_time 
			FROM weekly NATURAL JOIN section_weekly
			WHERE idsection IN
			(SELECT idsection FROM weekly NATURAL JOIN section_weekly WHERE idweekly = NEW.idweekly)
			AND idweekly <> NEW.idweekly
		);

	INSERT INTO same_faculty
		(SELECT idweekly, day_of_week, start_time, end_time
 			FROM faculty_class_section NATURAL JOIN section_weekly NATURAL JOIN weekly
 			WHERE faculty_name IN 
 						(SELECT faculty_name FROM faculty_class_section NATURAL JOIN section_weekly NATURAL JOIN weekly
 						WHERE NEW.idweekly = idweekly)
 			AND idweekly <> NEW.idweekly);

	INSERT INTO section_of_interest 
	(SELECT idweekly FROM weekly AS a 
	WHERE NEW.idweekly = a.idweekly
	AND 0 = ALL
		(SELECT (a.day_of_week & day_of_week)
		FROM same_section)
	OR (
		TRUE = ALL
			(SELECT (a.start_time < start_time AND a.end_time < start_time) FROM same_section)
 		OR TRUE = ALL
 			(SELECT (a.start_time > end_time AND a.end_time > end_time) FROM same_section)
		)
	);

	INSERT INTO faculty_of_interest
	(SELECT idweekly FROM weekly AS a 
	WHERE NEW.idweekly = a.idweekly
	AND 0 = ALL
		(SELECT (a.day_of_week & day_of_week)
		FROM same_faculty)
	OR (
		TRUE = ALL
			(SELECT (a.start_time < start_time AND a.end_time < start_time) FROM same_faculty)
 		OR TRUE = ALL
 			(SELECT (a.start_time > end_time AND a.end_time > end_time) FROM same_faculty)
		)
	);

	IF (NOT EXISTS (SELECT * FROM section_of_interest)) THEN
		DROP TABLE same_section;
		DROP TABLE same_faculty;
		DROP TABLE section_of_interest;
		DROP TABLE faculty_of_interest;
		RAISE EXCEPTION 'Conflicts with another subsection of this section';

	ELSIF (NOT EXISTS (SELECT * FROM faculty_of_interest)) THEN
		DROP TABLE same_section;
		DROP TABLE same_faculty;
		DROP TABLE section_of_interest;
		DROP TABLE faculty_of_interest;
		RAISE EXCEPTION 'Conflicts with another of facultys sections';
	END IF;
	
	DROP TABLE same_section;
	DROP TABLE same_faculty;
	DROP TABLE section_of_interest;
	DROP TABLE faculty_of_interest;
	RETURN NEW;

END;
$conflict_update$ LANGUAGE plpgsql;
-------------------------------------------
--
--
--
--
-------------------------------------------
-- TRIGGER insert_update_section_weekly
-------------------------------------------
CREATE TRIGGER insert_section_weekly
BEFORE INSERT ON section_weekly
FOR EACH ROW
EXECUTE PROCEDURE check_conflict();
-------------------------------------------
CREATE TRIGGER update_section_weekly
BEFORE UPDATE ON weekly
FOR EACH ROW
EXECUTE PROCEDURE check_conflict_update();



-------------------------------------------
-- PROCEDURE check_enrollment
-- Ensures that student does not enroll in a class that is overenrolled
-- USE WITH TRIGGER enroll_section
-------------------------------------------
CREATE OR REPLACE FUNCTION check_enrollment() RETURNS trigger AS $max$
 BEGIN
 	IF ((SELECT enrollment_limit FROM section WHERE idsection = NEW.idsection) <= (SELECT (COUNT(*)) FROM student_section__enrolled WHERE idsection = NEW.idsection GROUP BY idsection)) THEN
 	RAISE EXCEPTION 'Enrollment Limit Reached';
 	END IF;
 	RETURN NEW;
 END;
 $max$ LANGUAGE plpgsql;
-------------------------------------------
--
--
--
--
-------------------------------------------
-- TRIGGER enroll_section
-------------------------------------------
CREATE TRIGGER enroll_section
BEFORE INSERT ON student_section__enrolled
FOR EACH ROW
EXECUTE PROCEDURE check_enrollment();
-------------------------------------------



CREATE OR REPLACE FUNCTION pro_insert_cpqg() RETURNS trigger AS $pro_insert_cpqg$
BEGIN
	INSERT INTO cpqg_table
	(SELECT DISTINCT idcourse, faculty_name, idquarter, grade 
	FROM (SELECT DISTINCT faculty_name, idclass FROM faculty_class_section) AS fcs 
		NATURAL JOIN (SELECT * FROM quarter_course_class__instance NATURAL JOIN student_instance) AS yeah 
		NATURAL JOIN quarter WHERE NEW.idstudent_instance = idstudent_instance LIMIT 1);
	RETURN NULL;
END;
$pro_insert_cpqg$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION pro_insert_cpg() RETURNS trigger AS $pro_insert_cpg$
BEGIN
	INSERT INTO cpg_table (idcourse, faculty_name, grade)
	(SELECT DISTINCT idcourse, faculty_name, grade 
	FROM (SELECT DISTINCT faculty_name, idclass FROM faculty_class_section) AS fcs 
		NATURAL JOIN (SELECT * FROM quarter_course_class__instance NATURAL JOIN student_instance) AS yeah 
		WHERE NEW.idstudent_instance = idstudent_instance LIMIT 1);
	RETURN NULL;
END;
$pro_insert_cpg$ LANGUAGE plpgsql;

CREATE TRIGGER insert_cpqg
AFTER INSERT ON student_instance
FOR EACH ROW
EXECUTE PROCEDURE pro_insert_cpqg();

CREATE TRIGGER insert_cpg
AFTER INSERT ON student_instance
FOR EACH ROW
EXECUTE PROCEDURE pro_insert_cpg();





CREATE OR REPLACE FUNCTION pro_delete_cpg() RETURNS trigger AS $pro_delete_cpg$
BEGIN
	DELETE FROM cpg_table WHERE (idcourse, faculty_name, grade, idcpg) IN (SELECT * FROM cpg_table WHERE ((idcourse, faculty_name, grade, idcpg) IN (SELECT idcourse, faculty_name, grade, idcpg 
	FROM (SELECT DISTINCT faculty_name, idclass FROM faculty_class_section) AS fcs 
		NATURAL JOIN (SELECT * FROM quarter_course_class__instance NATURAL JOIN student_instance) AS yeah 
		NATURAL JOIN quarter WHERE OLD.idstudent_instance = idstudent_instance)) LIMIT 1);
	RETURN OLD;
END;
$pro_delete_cpg$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pro_delete_cpqg() RETURNS trigger AS $pro_delete_cpqg$
BEGIN
	DELETE FROM cpqg_table WHERE (idcourse, faculty_name, idquarter, grade, idcpqg) IN (SELECT * FROM cpqg_table WHERE ((idcourse, faculty_name, idquarter, grade, idcpqg) IN (SELECT idcourse, faculty_name, idquarter, grade, idcpqg 
	FROM (SELECT DISTINCT faculty_name, idclass FROM faculty_class_section) AS fcs 
		NATURAL JOIN (SELECT * FROM quarter_course_class__instance NATURAL JOIN student_instance) AS yeah 
		NATURAL JOIN quarter WHERE OLD.idstudent_instance = idstudent_instance)) LIMIT 1);
	RETURN OLD;
END;
$pro_delete_cpqg$ LANGUAGE plpgsql;

CREATE TRIGGER delete_cpqg
BEFORE DELETE ON student_instance
FOR EACH ROW
EXECUTE PROCEDURE pro_delete_cpqg();

CREATE TRIGGER delete_cpg
BEFORE DELETE ON student_instance
FOR EACH ROW
EXECUTE PROCEDURE pro_delete_cpg();

CREATE OR REPLACE FUNCTION pro_update_cpg() RETURNS trigger AS $pro_update_cpg$
BEGIN
	DELETE FROM cpg_table WHERE (idcourse, faculty_name, grade, idcpg) IN (SELECT * FROM cpg_table WHERE ((idcourse, faculty_name, grade, idcpg) IN (SELECT idcourse, faculty_name, grade, idcpg 
	FROM (SELECT DISTINCT faculty_name, idclass FROM faculty_class_section) AS fcs 
		NATURAL JOIN (SELECT * FROM quarter_course_class__instance NATURAL JOIN student_instance) AS yeah 
		NATURAL JOIN quarter WHERE OLD.idstudent_instance = idstudent_instance)) LIMIT 1);
	INSERT INTO cpg_table (idcourse, faculty_name, grade)
	(SELECT DISTINCT idcourse, faculty_name, grade 
	FROM (SELECT DISTINCT faculty_name, idclass FROM faculty_class_section) AS fcs 
		NATURAL JOIN (SELECT * FROM quarter_course_class__instance NATURAL JOIN student_instance) AS yeah 
		WHERE NEW.idstudent_instance = idstudent_instance);
	RETURN NEW;
END;
$pro_update_cpg$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pro_update_cpqg() RETURNS trigger AS $pro_update_cpqg$
BEGIN
	DELETE FROM cpqg_table WHERE (idcourse, faculty_name, idquarter, grade, idcpqg) IN (SELECT * FROM cpqg_table WHERE ((idcourse, faculty_name, idquarter, grade, idcpqg) IN (SELECT idcourse, faculty_name, idquarter, grade, idcpqg 
	FROM (SELECT DISTINCT faculty_name, idclass FROM faculty_class_section) AS fcs 
		NATURAL JOIN (SELECT * FROM quarter_course_class__instance NATURAL JOIN student_instance) AS yeah 
		NATURAL JOIN quarter WHERE OLD.idstudent_instance = idstudent_instance)) LIMIT 1);
	INSERT INTO cpqg_table
	(SELECT DISTINCT idcourse, faculty_name, idquarter, grade 
	FROM (SELECT DISTINCT faculty_name, idclass FROM faculty_class_section) AS fcs 
		NATURAL JOIN (SELECT * FROM quarter_course_class__instance NATURAL JOIN student_instance) AS yeah 
		NATURAL JOIN quarter WHERE NEW.idstudent_instance = idstudent_instance LIMIT 1);
	RETURN NEW;
END;
$pro_update_cpqg$ LANGUAGE plpgsql;


CREATE TRIGGER update_cpqg
AFTER UPDATE ON student_instance
FOR EACH ROW
EXECUTE PROCEDURE pro_update_cpqg();

CREATE TRIGGER update_cpg
AFTER UPDATE ON student_instance
FOR EACH ROW
EXECUTE PROCEDURE pro_update_cpg();




-------------------------------------------
-- PROCEDURE check_section_conflict
-- Ensures that professor does not start teaching a section that conflicts with currently taught sections
-- USE WITH TRIGGER update_faculty_class_section
-------------------------------------------
 CREATE OR REPLACE FUNCTION check_section_conflict() RETURNS trigger AS $secconflict$
 BEGIN
 	CREATE TEMPORARY TABLE same_faculty (
		idweekly integer,
		day_of_week integer,
		start_time TIME,
		end_time TIME
	);

	CREATE TEMPORARY TABLE updated_section (
		idweekly integer,
		day_of_week integer,
		start_time TIME,
		end_time TIME
	);

	CREATE TEMPORARY TABLE faculty_of_interest (
		idweekly integer
	);

	INSERT INTO same_faculty
		(SELECT idweekly, day_of_week, start_time, end_time
 			FROM faculty_class_section NATURAL JOIN section_weekly NATURAL JOIN weekly
 			WHERE faculty_name = NEW.faculty_name);

 	INSERT INTO updated_section
 		(SELECT idweekly, day_of_week, start_time, end_time
 			FROM section_weekly NATURAL JOIN weekly
 			WHERE idsection = NEW.idsection);

 	INSERT INTO faculty_of_interest
 		(
 		SELECT * FROM updated_section AS a 
 		WHERE 0 <> ANY
 			(SELECT (a.day_of_week & day_of_week) FROM same_faculty)
 		OR TRUE <> ANY
 			(SELECT (a.start_time < start_time AND a.end_time < start_time) FROM same_section)
 		OR TRUE = ALL
 			(SELECT (a.start_time > end_time AND a.end_time > end_time) FROM same_section)
 		);

 	IF (EXISTS (SELECT * FROM faculty_of_interest)) THEN
		DROP TABLE same_faculty;
		DROP TABLE updated_section;
		DROP TABLE faculty_of_interest;
 		RAISE EXCEPTION 'Conflicts with other sections faculty is teaching';
 	END IF;
 	
 	DROP TABLE same_faculty;
	DROP TABLE updated_section;
	DROP TABLE faculty_of_interest;
	RETURN NEW;
END
$secconflict$ LANGUAGE plpgsql;
-------------------------------------------
--
--
--
--
-------------------------------------------
-- TRIGGER update_faculty_class_section
-------------------------------------------
 CREATE TRIGGER update_faculty_class_section
 BEFORE UPDATE OF faculty_name, idsection ON faculty_class_section
 FOR EACH ROW
 EXECUTE PROCEDURE check_section_conflict();

 
 
 
 
 
 -------------------------------------------
-- PROCEDURE check_student_attends
-- Ensures that redundant attendance doesn't exist for same quarter
-- USE WITH TRIGGER enroll_section
-------------------------------------------
CREATE OR REPLACE FUNCTION check_student_attends() RETURNS trigger AS $attends$
 BEGIN
 	IF EXISTS(
 		(SELECT * FROM student_quarter__attends WHERE idstudent = NEW.idstudent AND idquarter=NEW.idquarter)
 	) THEN RAISE EXCEPTION 'Student is enrolled in that quarter already.';
 	END IF;
 	RETURN NEW;
 END;
 $attends$ LANGUAGE plpgsql;
-------------------------------------------
--
--
--
--
-------------------------------------------
-- TRIGGER student_attends_entry
-------------------------------------------
CREATE TRIGGER student_attends_entry
BEFORE INSERT ON student_quarter__attends
FOR EACH ROW
EXECUTE PROCEDURE check_student_attends();
-------------------------------------------
