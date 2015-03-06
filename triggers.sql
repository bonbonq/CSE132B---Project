-------------------------------------------
-- PROCECURE checkForConflict
-- Ensures no time conflict occurs within a section
-- Or within a Professor's regular sections
-- USE WITH TRIGGER insert_update_section_weekly
-------------------------------------------
CREATE OR REPLACE FUNCTION checkForConflict() RETURNS trigger AS $conflict$
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
			FROM weekly 	
			WHERE idsection = NEW.idsection
			AND idweekly <> NEW.idweekly
		);

	INSERT INTO same_faculty
		(SELECT idweekly, day_of_week, start_time, end_time FROM
 			FROM faculty_class_section NATURAL JOIN section_weekly NATURAL JOIN weekly
 			WHERE faculty_name IN 
 						(SELECT faculty_name FROM faculty_class_section NATURAL JOIN section_weekly NATURAL JOIN weekly
 						WHERE NEW.idweekly = weekly);

	INSERT INTO section_of_interest 
	(SELECT idweekly FROM weekly AS a 
	WHERE NEW.idweekly = a.idweekly
	AND 0 = ALL
		(SELECT (a.day_of_week & day_of_week)
		FROM same_section)
	OR (
		(TRUE,TRUE) = ALL
			(SELECT (a.start_time < start_time AND a.end_time < start_time) FROM same_section)
 		OR (TRUE,TRUE) = ALL
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
		(TRUE,TRUE) = ALL
			(SELECT (a.start_time < start_time AND a.end_time < start_time) FROM same_faculty)
 		OR (TRUE,TRUE) = ALL
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
	END IF;
	
	DROP TABLE same_section;
	DROP TABLE same_faculty;
	DROP TABLE section_of_interest;
	DROP TABLE faculty_of_interest;
	RETURN NEW;

END;
$conflict$ LANGUAGE plpgsql;
-------------------------------------------
--
--
--
--
-------------------------------------------
-- TRIGGER insert_update_section_weekly
-------------------------------------------
CREATE TRIGGER insert_update_section_weekly
BEFORE INSERT OR UPDATE ON section_weekly
FOR EACH ROW
EXECUTE PROCEDURE checkForConflict()
-------------------------------------------




-------------------------------------------
-- PROCEDURE check_enrollment
-- Ensures that student does not enroll in a class that is overenrolled
-- USE WITH TRIGGER enroll_section
-------------------------------------------
CREATE OR REPLACE FUNCTION check_enrollment() RETURNS trigger AS $max$
 BEGIN
 	IF ((SELECT enrollment_limit FROM section WHERE idsection = NEW.idsection) <= (SELECT COUNT(*) FROM student_section__enrollment WHERE idsection = NEW.idsection GROUP BY idsection)) THEN
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
BEFORE INSERT ON student_section__enrollment
FOR EACH STATEMENT
EXECUTE PROCEDURE check_enrollment()
-------------------------------------------

