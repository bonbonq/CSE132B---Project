<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Course Entry Form</title>
</head>

<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.sql.*" %>
<%@page import="org.postgresql.*" %>

<%
Connection conn = null;

try {
	//Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost/CSE132B?");
	
	String action = request.getParameter("action");
	System.out.println("action: "+action);
	/* Insert Action */
	if (action!=null && action.equals("insert")) {
		
		String course_number = request.getParameter("course_number");
		String[] prereqs = request.getParameterValues("prereq");
		String min_units = request.getParameter("min_units");
		String max_units = request.getParameter("max_units");
		String grade_type = request.getParameter("grade_type");
		String lab = request.getParameter("lab");
		
		System.out.println("Course Number: " + course_number);
		System.out.print("Prereq: ");
		if (prereqs!=null){
			for(String prereq : prereqs)
			{
				System.out.print(prereq + ", ");
			}
		}
		else{
			System.out.println("none");
		}
		System.out.println("Unit range: " + min_units + " - " + max_units);
		System.out.println("Grade Type: " + grade_type);
		System.out.println("Lab? " + lab);
            
	}
	
	
} catch (SQLException e) {
	e.printStackTrace();
    String message = "Failure: Your signup failed " + e.getMessage();
}
	
%>

<!-- HTML Body Start -->
<body>

	<h2>Course Entry Form</h2>

	<!-- Course Insertion Form -->
	<form action="course_entry_form.jsp" method="POST">
		
		<div class="form-group">
			Course Number: (ex. CSE132) 
			<br>
			<input type="text" name="course_number" required>
		</div>
		<p>
		
		<div class="form-group">
			Prerequisite courses:
			<br>
			<input type="checkbox" name="prereq" value="consent">Consent of Instructor
			<br>
			<input type="checkbox" name="prereq" value="test_course_name">Test Course Name
			<br>
		</div>	
		<p>
		
		<div class="form-group">
			Minimum Units: <input type="number" name="min_units" min="0" required>
			<br>
			Maximum Units: <input type="number" name="max_units" min="0" required>
			<br>
		</div>
		<p>
		
		<div class="form-group">
			Grade Option(s) Accepted:
			<br>
			<input type="radio" name="grade_type" value="letter" checked>Letter Grade
			<br>
			<input type="radio" name="grade_type" value="s_u">S/U
			<br>
			<input type="radio" name="grade_type" value="both">Letter Grade and S/U
			<br>
		</div>
		<p>
		
		<div class="form-group">
			Lab work required?
			<br>
			<input type="radio" name="lab" value="yes">Yes
			<br>
			<input type="radio" name="lab" value="no" checked>No
		</div>
		<p>
		
		<button type="submit" name="action" value="insert">Submit</button>
		
	</form>


</body>
<!-- HTML Body End -->

</html>