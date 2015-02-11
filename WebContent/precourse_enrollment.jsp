<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>PreCourse Enrollment</title>
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

try {
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost/CSE132B?");
	
} catch (Exception e) {
	e.printStackTrace();
	out.println("<h1>org.postgresql.Driver Not Found</h1>");
}

/* =========================== */
/* Generate Form Fields Action */
/* =========================== */

ResultSet quarter_rs = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	PreparedStatement quarter_stmt = conn.prepareStatement("SELECT * FROM quarter");
	/* The below two statements are not closed, this might cause issues later... */
	quarter_rs = quarter_stmt.executeQuery();
	
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


<!-- HTML Body Start -->
<body>

	<h2>PreCourse Enrollment Form</h2>

	<!-- Insertion Form -->
	<form action="course_enrollment.jsp" method="POST">
		
		<div>
			Choose Quarter for Enrollment:
			<select name="quarter">
				<%
				if (quarter_rs.isBeforeFirst())
				{
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
		
		<button type="submit" name="action" value="precourse">Submit</button>
		
	</form>


</body>
<!-- HTML Body End -->

<%

if (conn != null)
	conn.close();
%>

</html>