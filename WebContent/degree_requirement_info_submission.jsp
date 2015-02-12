<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Degree Requirement Submission</title>

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

/* ============= */
/* Insert Action */
/* ============= */
if(action!=null && action.equals("insert")){
	
	PreparedStatement update = conn.prepareStatement(	
			"INSERT INTO degree (total_units, name, type) " +
			"SELECT ?,?,?");
	update.setString(1, request.getParameter("total_units"));
	update.setString(2, request.getParameter("name"));
	update.setString(3, request.getParameter("type"));
	
	
	if (update.executeUpdate()==1) {
		%>
		<h1>Successfully Updated!</h1>
		<%
	}
	else {
		%>
		<h1>Update has failed!</h1>
		<%
	}
}

%>


</head>
<body>
<h2>Degree Creation and Requirements</h2>
<!--  Insertion Form -->
	<form action="degree_requirement_info_submission.jsp" method="POST">
		
		<div>
			Name: <input type="text" name="name" required>
			<br>
		</div>
		<p>
		
		<div>
			Type: <input type="text" name="type" required>
			<br>
		</div>
		<p>
		
		<div>
			Units: <input type="number" name="total_units" required>
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