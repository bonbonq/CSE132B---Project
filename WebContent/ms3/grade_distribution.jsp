<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Grade Distribution</title>
</head>
<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.sql.*" %>
<%@page import="org.postgresql.*" %>

<!-- Java Portion start -->
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
String faculty_name;
int idinstance;

/* ================== */
/* INSERT FORM ACTION */
/* ================== */
if (action!=null && action.equals("submit")) {
	
	try {
		conn.setAutoCommit(false);
		
		if(request.getParameter("idquarter").equals("None"))
			sql1 =	"SELECT grade, COUNT(grade) FROM cpg WHERE cpg.idcourse=? AND cpg.faculty_name=? GROUP BY grade";
		else
			sql1 =	"SELECT grade, COUNT(grade) FROM cpqg WHERE cpqg.idcourse=? AND cpqg.faculty_name=? AND cpqg.idquarter=? GROUP BY grade";
		
		pstmt1 = conn.prepareStatement(sql1);
		pstmt1.setInt(1, Integer.parseInt(request.getParameter("idcourse")));
		pstmt1.setString(2, request.getParameter("faculty_name"));

		if (pstmt1.execute())
		{
			ResultSet rs1 = pstmt1.getResultSet();
			if (rs1.isBeforeFirst()){
				while(rs1.next()) {
					String grade = rs1.getString("grade");
					int number = rs1.getInt("count");
					%><h2><%=grade %> - <%=number %></h2><%
				}
			}
		}
		else
		{
			conn.rollback();
			throw new SQLException("Insert into faculty_instance_teaches failed.");
		}
		
		conn.commit();
		conn.setAutoCommit(true);
		
	} catch (SQLException e) {
		conn.rollback();
		e.printStackTrace();
        String message = "Failure: " + e.getMessage();
	   	%>
		<h1><%=message %></h1>
		<%
	} finally {
		if (pstmt1 != null)
			pstmt1.close();
	}
	
}

/* =========================== */
/* Generate Form Fields Action */
/* =========================== */

ResultSet course_rs = null;
ResultSet faculty_rs = null;
ResultSet quarter_rs = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	course_rs = conn.prepareStatement("SELECT * FROM course NATURAL JOIN course_coursenumber NATURAL JOIN coursenumber", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE).executeQuery();
	faculty_rs = conn.prepareStatement("SELECT * FROM faculty", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE).executeQuery();
	quarter_rs = conn.prepareStatement("SELECT * FROM quarter", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE).executeQuery();

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
	<h2>Faculty Is Teaching Course Form</h2>
	
	<!-- Student Insertion Form -->
	<form action="grade_distribution" method="POST">
		
		<div>
			Course:
			<select name="idcourse">
				<%
				if (course_rs.isBeforeFirst())
				{
					while(course_rs.next()){
						%>
						<option value=<%=course_rs.getString("idcourse")%>><%=course_rs.getString("number")%></option>
						<%
					}
				}
				%>
			</select>
		</div>
		<p>
		
		<div>
			Faculty:
			<select name="faculty_name">
				<%
				if (faculty_rs.isBeforeFirst())
				{
					while(faculty_rs.next()){
						%>
						<option value=<%=faculty_rs.getString("faculty_name")%>><%=faculty_rs.getString("faculty_name")%></option>
						<%
					}
				}
				%>
			</select>
		</div>
		<p>
		
		<div>
			Quarter:
			<select name="idquarter">
				<%
				if (quarter_rs.isBeforeFirst())
				{
					%><option value="None">None</option><%
					while(quarter_rs.next()){
						%>
						<option value=<%=quarter_rs.getString("idquarter")%>><%=quarter_rs.getString("year")%> - <%=quarter_rs.getString("season")%></option>
						<%
					}
				}
				%>
			</select>
		</div>
		<p>
		
		<button type="submit" name="action" value="submit">Submit</button>
		
	</form>
	
	<br>
	<br>
	
	
</body>
<!-- HTML Body End -->
<%

if (conn != null)
	conn.close();
%>

</html>