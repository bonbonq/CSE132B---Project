<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Course Enrollment</title>
</head>
<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.sql.*" %>
<%@page import="org.postgresql.*" %>

<!-- Java Part Start -->

<%

boolean debug= true;
/* Create DB connection */
boolean success = false;
Connection conn = null;
String sql1 = "";
String sql2 = "";
String sql3 = "";
String sql4 = "";
String sql5 = "";
PreparedStatement pstmt1 = null;
PreparedStatement pstmt2 = null;
PreparedStatement pstmt3 = null;
PreparedStatement pstmt4 = null;
PreparedStatement pstmt5 = null;

try {
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost/CSE132B?");
	
} catch (Exception e) {
	e.printStackTrace();
	out.println("<h1>org.postgresql.Driver Not Found</h1>");
}

String action = request.getParameter("action");
int idquarter = 0;
int idinstance = 0;



/* ============================== */
/* Continue from course action */
/* ============================== */

if (action!=null && action.equals("course")) {
	idquarter = Integer.parseInt(request.getParameter("idquarter"));
	idinstance = Integer.parseInt(request.getParameter("idinstance"));
	if (idquarter==0 || idinstance==0)
		response.sendRedirect("precourse_enrollment.jsp");
}


/* ================== */
/* INSERT FORM action */
/* ================== */
else if(action!=null && action.equals("insert")){
	
	/* Get the enrollment limit */
	int enrollment_limit = 0;
	PreparedStatement insert0_1 = conn.prepareStatement(	
			"SELECT * FROM section WHERE idsection=?");
	insert0_1.setInt(1, Integer.parseInt(request.getParameter("idsection")));
	if (insert0_1.execute())
	{
		ResultSet rs0 = insert0_1.getResultSet();
		if (rs0.next()){
			enrollment_limit = rs0.getInt("enrollment_limit");
		}
	}
	else
		%><h1>insert0_1 failed.</h1><%
	
	/* Check current enrolled number */
	int currently_enrolled = 0;
	PreparedStatement insert0_2 = conn.prepareStatement(	
			"SELECT COUNT(*) FROM student_section__enrolled WHERE idsection=?");
	insert0_2.setInt(1, Integer.parseInt(request.getParameter("idsection")));
	if (insert0_2.execute())
	{
		ResultSet rs0_2 = insert0_2.getResultSet();
		if (rs0_2.next()){
			currently_enrolled = rs0_2.getInt("count");
		}
	}
	else
		%><h1>insert0_2 failed.</h1><%
	

	System.out.println("currently_enrolled " + currently_enrolled);
	System.out.println("enrollment_limit " + enrollment_limit);

	
	/* Add to student_instance */
	int success_counter = 0;
	
	PreparedStatement insert1 = conn.prepareStatement(	
			"INSERT INTO student_instance (idstudent, idinstance, grade)" +
			"SELECT ?,?,?" +
			"WHERE NOT EXISTS (" +
				"SELECT idstudent_instance FROM student_instance " +
					"WHERE idstudent=? AND idinstance=?" +
			")");
	insert1.setInt(1, Integer.parseInt(request.getParameter("idstudent")));
	insert1.setInt(2, Integer.parseInt(request.getParameter("idinstance")));
	insert1.setString(3, request.getParameter("grade"));
	insert1.setInt(4, Integer.parseInt(request.getParameter("idstudent")));
	insert1.setInt(5, Integer.parseInt(request.getParameter("idinstance")));
	if (insert1.executeUpdate()==1) {
		success_counter++;
	}
	else 
		%><h1>Insert into student_instance failed.</h1><%
	
		
	/* Add to student_section__enrolled */
	if (currently_enrolled < enrollment_limit) {
		
		PreparedStatement insert2 = conn.prepareStatement(	
				"INSERT INTO student_section__enrolled (idstudent, idsection)" +
				"SELECT ?,?" +
				"WHERE NOT EXISTS (" +
					"SELECT idstudent_section__enrolled FROM student_section__enrolled " +
						"WHERE idstudent=? AND idsection=?" +
				")");
		insert2.setInt(1, Integer.parseInt(request.getParameter("idstudent")));
		insert2.setInt(2, Integer.parseInt(request.getParameter("idsection")));
		insert2.setInt(3, Integer.parseInt(request.getParameter("idstudent")));
		insert2.setInt(4, Integer.parseInt(request.getParameter("idsection")));
		if (insert2.executeUpdate()==1 && success_counter==1) {
			response.sendRedirect("section_enrollment_confirmation.jsp");
		}
		else 
			%><h1>Insert into student_section__enrolled failed.</h1><%
			
	}
	/* Add to student_section__waitlist */
	else {
		
		PreparedStatement insert2 = conn.prepareStatement(	
				"INSERT INTO student_section__waitlist (idstudent, idsection)" +
				"SELECT ?,?" +
				"WHERE NOT EXISTS (" +
					"SELECT idstudent_section__waitlist FROM student_section__waitlist " +
						"WHERE idstudent=? AND idsection=?" +
				")");
		insert2.setInt(1, Integer.parseInt(request.getParameter("idstudent")));
		insert2.setInt(2, Integer.parseInt(request.getParameter("idsection")));
		insert2.setInt(3, Integer.parseInt(request.getParameter("idstudent")));
		insert2.setInt(4, Integer.parseInt(request.getParameter("idsection")));
		if (insert2.executeUpdate()==1 && success_counter==1) {
			response.sendRedirect("section_waitlist_confirmation.jsp");
		}
		else 
			%><h1>Insert into student_section__waitlist failed.</h1><%
			
	}

	
}


/* =========================== */
/* Generate Form Fields Action */
/* =========================== */

ResultSet instance_rs = null;
ResultSet faculty_rs = null;
ResultSet degree_rs = null;
String title = "";
String number = "";
String max_units = "";
String min_units = "";
String grade_option_type = "";

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	PreparedStatement instance_stmt = conn.prepareStatement(
			"SELECT DISTINCT * FROM quarter_course_class__instance " +
			"NATURAL JOIN course NATURAL JOIN class NATURAL JOIN course_coursenumber " +
			"NATURAL JOIN coursenumber WHERE idinstance=?");
	instance_stmt.setInt(1, idinstance);
	if (instance_stmt.execute()) {
		instance_rs = instance_stmt.getResultSet();
		if (instance_rs.next()) {
			title = instance_rs.getString("title");
			number = instance_rs.getString("number");
			max_units = instance_rs.getString("max_units");
			min_units = instance_rs.getString("min_units");
			grade_option_type = instance_rs.getString("grade_option_type");
		}
	}
	
	/* fetch the info */
	
	
	conn.commit();
	conn.setAutoCommit(true);
	
} catch(SQLException e) {
	conn.rollback();
	e.printStackTrace();
	String message = "Failure: Unable to retrieve dropdown info - " + e.getMessage();
	%>
	<h1><%=message %></h1>
	<%
} 
%>

<!-- HTML body part -->
<body>
	
	<a href='index.jsp'><button>Home</button></a>
	<h2>Course Enrollment Form</h2>
	<h3><%= number%>  -  <%= title%></h3>

	<!-- Insertion Form -->
	<form action="postcourse_enrollment.jsp" method="POST">
		
		<input type="hidden" name="idquarter" value="<%=idquarter %>">
		<input type="hidden" name="idinstance" value="<%=idinstance %>">
		
		<div>
			PID: <input type="text" name="idstudent" required>
			<br>
		</div>
		<p>
		
		<div>
			<br>
			Section Number: <input type="number" name="idsection" required>
			<br>
		</div>
		<p>
		
		<div>
			<br>
			Units: <input type="number" name="units" min=<%=min_units %> max=<%=max_units %> required>
			<p>
			Units must be between <%=min_units %> to <%=max_units %> units.
			<br>
		</div>
		<p>
		
		<div>
			Grade Type:
			<br>
			<%
			if (grade_option_type.equals("letter")) { %>
				<input type="radio" name="grade_option_type" value="letter" checked>Letter</input><br>
			<% }
			else if (grade_option_type.equals("su")) { %>
				<input type="radio" name="grade_option_type" value="su" checked>S/U</input>
			<% }
			else { %>
				<input type="radio" name="grade_option_type" value="letter" checked>Letter</input><br>
				<input type="radio" name="grade_option_type" value="su" >S/U</input>
			<% }
			%>
		</div>
		<p>
		
		<div>
			Grade: <input type="text" name="grade" placeholder="PENDING" required>
			<p>
			<i>Grade can be A, B, C, D, F, S, U, PENDING</i>
			<br>
		</div>
		<p>
		
		<button type="submit" name="action" value="insert">Submit</button>
		
	</form>


</body>
<!-- HTML Body End -->

<%

if (conn != null)
	conn.close();
%>

</html>