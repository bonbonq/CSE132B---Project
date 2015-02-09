<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Previous Degree Entry Form</title>
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
String school_name;
String degree_name;
String degree_type;
int idschool = 0;
ResultSet school_rs = null;
ResultSet degree_rs = null;

/* Insert Action */
if (action!=null && action.equals("insert")) {
	
	school_name = request.getParameter("school_name");
	if (school_name.equals("other"))
		school_name = request.getParameter("other_school_name");
	degree_name = request.getParameter("degree_name");
	if (degree_name.equals("other"))
		degree_name = request.getParameter("other_degree_name");
	degree_type = request.getParameter("degree_type");
	if (debug){
		System.out.println("school_name: " + school_name);
		System.out.println("degree_name: " + degree_name);
	}
	
	try {
		conn.setAutoCommit(false);
		
		/* Only insert if "other" is chosen */
		if(request.getParameter("school_name").equals("other")){
			success = false;
			/* Insert into school */
			sql1 =	"INSERT INTO school (name) "+
					"SELECT ?" +
					"RETURNING idschool";
			pstmt1 = conn.prepareStatement(sql1);
			pstmt1.setString(1, school_name);
			if (pstmt1.execute())
			{
				ResultSet rs1 = pstmt1.getResultSet();
				if (rs1.next()){
					if (rs1.getInt("idschool") > 0)
						success = true;
				}
			}
			else
			{
				conn.rollback();
				throw new SQLException("Insert into school failed.");
			}
		}
		
		/* Only insert if "other" is chosen */
		if(request.getParameter("degree_name").equals("other")){
			success = false;
			/* Insert into previousdegree */
			sql2 =	"INSERT INTO previousdegree (type, field) "+
					"SELECT ?,?" +
					"RETURNING idpreviousdegree";
			pstmt2 = conn.prepareStatement(sql2);
			pstmt2.setString(1, degree_type);
			pstmt2.setString(2, degree_name);
			if (pstmt2.execute())
			{
				ResultSet rs2 = pstmt2.getResultSet();
				if (rs2.next()){
					if(rs2.getInt("idpreviousdegree") > 0)
						success = true;
				}
			}
			else
			{
				conn.rollback();
				throw new SQLException("Insert into previousdegree failed.");
			}
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

	<h2>Previous Degree Entry Form</h2>
	
	<!-- Insertion Form -->
	<form action="previous_degree_form.jsp" method="POST">
		
		<div>
			School Name:
			<select name="school_name" required>
				<%
				if (school_rs.isBeforeFirst())
				{
					while(school_rs.next()){
						%>
						<option value=<%=school_rs.getString("name")%>><%=school_rs.getString("name")%></option>
						<%
					}
				}
				%>
				<option value="other">Other</option>
			</select>
			<p>
			If Other, please enter school name:
			<br>
			<input type="text" name="other_school_name">
			<br>
		</div>
		<p>
		
		<div>
			Degree Name:
			<select name="degree_name" required>
				<%
				if (degree_rs.isBeforeFirst())
				{
					while(degree_rs.next()){
						%>
						<option value=<%=degree_rs.getString("field")%>><%=degree_rs.getString("field")%></option>
						<%
					}
				}
				%>
				<option value="other">Other</option>
			</select>
			<p>
			If Other, please enter degree name:
			<br>
			<input type="text" name="other_degree_name">
			<br>
		</div>
		<p>
		
		<div>
			Degree Type: 
			<br>
			<input type="radio" name="degree_type" value="high_school" checked>High School<br>
			<input type="radio" name="degree_type" value="vocation">Vocation<br>
			<input type="radio" name="degree_type" value="BA">BA<br>
			<input type="radio" name="degree_type" value="BS">BS<br>
			<input type="radio" name="degree_type" value="MS">MS<br>
			<input type="radio" name="degree_type" value="PHD">PhD<br>
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