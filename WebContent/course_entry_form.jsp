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

<!-- Java Part start -->
<%
boolean debug = false;
boolean success = true;

/* Create DB connection */
Connection conn = null;

try {
	//Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost/CSE132B?");
	
} catch (ClassNotFoundException e) {
	e.printStackTrace();
	out.println("<h1>org.postgresql.Driver Not Found</h1>");
}


String action = request.getParameter("action");
String course_number;
String[] prereqs;
int min_units;
int max_units;
String grade_type;
String lab;
if (debug)
	System.out.println("action: "+action);


/* Insert Action */
if (action!=null && action.equals("insert")) {
	
	course_number = request.getParameter("course_number");
	prereqs = request.getParameterValues("prereq");
	min_units = Integer.parseInt(request.getParameter("min_units"));
	max_units = Integer.parseInt(request.getParameter("max_units"));
	grade_type = request.getParameter("grade_type");
	lab = request.getParameter("lab");
	
	/* Print statements for parameters */
	if (debug){
		
		System.out.println("Course Number: " + course_number);
		System.out.print("Prereq: ");
		if (prereqs!=null){
			for(String prereq : prereqs)
			{
				System.out.print(prereq + ", ");
			}
			System.out.println("");
		}
		else{
			System.out.println("none");
		}
		System.out.println("Unit range: " + min_units + " - " + max_units);
		System.out.println("Grade Type: " + grade_type);
		System.out.println("Lab? " + lab);	
		
	}
	
	if(course_number!=null && max_units >= min_units && grade_type!=null && lab!=null) {
		String sql = "";
		PreparedStatement pstmt = null;
		try{
			// Create the statement
			conn.setAutoCommit(false);
			// Insert the user into table users, only if it does not already exist
			sql =	"INSERT INTO users (name, role, age, state) " +
					"SELECT ?,?,?,? " +
					"WHERE NOT EXISTS (SELECT name FROM users WHERE name = ?);" ;
			//System.out.print(sql + "\n");	
										
			/* pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, name);
			pstmt.setString(2, role);
			pstmt.setInt(3, Integer.parseInt(age));
			pstmt.setString(4, state);
			pstmt.setString(5, name); */

			int count1 = pstmt.executeUpdate();

			if(count1 == 1)
			{
				conn.commit();
				success = true;
			}
			else
			{
				conn.rollback();
				throw new SQLException("Your signup failed!");
			}

			conn.setAutoCommit(true);
			conn.close();
			
		} catch (SQLException e) {
			e.printStackTrace();
            String message = "Failure: Your signup failed " + e.getMessage();
		   	     	%>
					<h1><%=message %></h1>
					<%
		}
		
	/* else will happen if parameters are not correct */
	}
	else {
		success = false;
	}
        
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