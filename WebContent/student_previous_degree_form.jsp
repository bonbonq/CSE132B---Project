<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Student's Previous Degree Entry Form</title>
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
int pid;
int school;
int degree;
ResultSet school_rs = null;
ResultSet degree_rs = null;

/* Insert Action */
if (action!=null && action.equals("insert")) {
	
	pid = Integer.parseInt(request.getParameter("pid"));
	school = Integer.parseInt(request.getParameter("school"));
	degree = Integer.parseInt(request.getParameter("degree"));
	
	if (debug){
		System.out.println("pid: " + pid);
		System.out.println("school: " + school);
		System.out.println("degree: " + degree);
	}
	
	try {
		conn.setAutoCommit(false);
		
		/* Insert into school */
		sql1 =	"INSERT INTO student_degree_school (idstudent, idpreviousdegree, idschool) "+
				"SELECT ?,?,?" +
				"WHERE NOT EXISTS (" +
					"SELECT idstudent_degree_school FROM student_degree_school WHERE idstudent=? AND idpreviousdegree=? AND idschool=?" +
				")" +
				" AND " +
				"EXISTS (" +
					"SELECT idstudent FROM student WHERE idstudent=?" +
				")" +
				"RETURNING idstudent_degree_school";
		pstmt1 = conn.prepareStatement(sql1);
		pstmt1.setInt(1, pid);
		pstmt1.setInt(2, degree);
		pstmt1.setInt(3, school);
		pstmt1.setInt(4, pid);
		pstmt1.setInt(5, degree);
		pstmt1.setInt(6, school);
		pstmt1.setInt(7, pid);
		if (pstmt1.execute())
		{
			ResultSet rs1 = pstmt1.getResultSet();
			if (rs1.next()){
				if (rs1.getInt("idstudent_degree_school") > 0)
					success = true;
			}
		}
		else
		{
			conn.rollback();
			throw new SQLException("Insert into student_degree_school failed.");
		}
		
		conn.commit();
		conn.setAutoCommit(true);
		
	} catch (SQLException e) {
		conn.rollback();
		e.printStackTrace();
        String message = "Failure: Your entry failed " + e.getMessage();
	   	%>
		<h1><%=message %></h1>
		<%
	} finally {
		if (pstmt1 != null)
			pstmt1.close();
	}
	
	if (success) {
		String message = "Successfully added new previous degree";
		%>
		<h1><%=message %></h1>
		<%
	}
	else {
		String message = "Please make sure student doesn't already have the degree.";
		%>
		<h1><%=message %></h1>
		<%
	}

}

/* Generate Form Fields Action */
//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	PreparedStatement school_stmt = conn.prepareStatement("SELECT * FROM school");
	PreparedStatement degree_stmt = conn.prepareStatement("SELECT * FROM previousdegree");
	/* The below two statements are not closed, this might cause issues later... */
	school_rs = school_stmt.executeQuery();
	degree_rs = degree_stmt.executeQuery();
	
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

	<h2>Student's Previous Earned Degree Entry Form</h2>
	
	<!-- Insertion Form -->
	<form action="student_previous_degree_form.jsp" method="POST">
		
		<div>
			PID: <input type="number" name="pid" required>
			<br>
		</div>
		<p>
		
		<div>
			School Name:
			<select name="school">
				<%
				if (school_rs.isBeforeFirst())
				{
					while(school_rs.next()){
						%>
						<option value=<%=school_rs.getString("idschool")%>><%=school_rs.getString("name")%></option>
						<%
					}
				}
				%>
			</select>
		</div>
		<p>
		
		<div>
			Degree Name:
			<select name="degree">
				<%
				if (degree_rs.isBeforeFirst())
				{
					while(degree_rs.next()){
						%>
						<option value=<%=degree_rs.getString("idpreviousdegree")%>><%=degree_rs.getString("field")%></option>
						<%
					}
				}
				%>
			</select>
		</div>
		<p>

		<button type="submit" name="action" value="insert">Submit</button>
		
	</form>

</body>
</html>