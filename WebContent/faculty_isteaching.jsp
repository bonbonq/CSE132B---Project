<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Faculty Is Teaching Form</title>
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
if (action!=null && action.equals("insert")) {
	
	idinstance = Integer.parseInt(request.getParameter("course"));
	faculty_name = request.getParameter("faculty_name");
	
	try {
		conn.setAutoCommit(false);
		
		/* Insert into school */
		sql1 =	"INSERT INTO faculty_instance_teaches (faculty_name, idinstance) SELECT ?,? WHERE NOT EXISTS (SELECT idfaculty_instance_teaches FROM faculty_instance_teaches WHERE faculty_name=? and idinstance=?) RETURNING idfaculty_instance_teaches";
		pstmt1 = conn.prepareStatement(sql1);
		pstmt1.setString(1, faculty_name);
		pstmt1.setInt(2, idinstance);
		pstmt1.setString(3, faculty_name);
		pstmt1.setInt(4, idinstance);

		if (pstmt1.execute())
		{
			ResultSet rs1 = pstmt1.getResultSet();
			if (rs1.next()){
				if (rs1.getInt("idfaculty_instance_teaches") > 0)
					success = true;
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
        String message = "Failure: Your entry failed " + e.getMessage();
	   	%>
		<h1><%=message %></h1>
		<%
	} finally {
		if (pstmt1 != null)
			pstmt1.close();
	}
	
	if (success) {
		String message = "Successfully added new course that faculty is teaching.";
		%>
		<h1><%=message %></h1>
		<%
	}
	else {
		String message = "Please make " + faculty_name + "has not already been registered as teaching the course: " + idinstance;
		%>
		<h1><%=message %></h1>
		<%
	}
	
}

/* =========================== */
/* Generate Form Fields Action */
/* =========================== */

ResultSet course_rs = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	int current_year = Calendar.getInstance().get(Calendar.YEAR);
	PreparedStatement course_stmt = conn.prepareStatement("SELECT * FROM quarter_course_class__instance NATURAL JOIN quarter NATURAL JOIN course_coursenumber WHERE year=? AND season='winter'");
	course_stmt.setInt(1, current_year);
	/* The below two statements are not closed, this might cause issues later... */
	course_rs = course_stmt.executeQuery();

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

	<h2>Faculty Is Teaching Course Form</h2>
	
	<!-- Student Insertion Form -->
	<form action="faculty_isteaching.jsp" method="POST">
		
		<div>
			Faculty Name: <input type="text" name="faculty_name" required>
			<br>
		</div>
		<p>
		
		<div>
			Course:
			<select name="course">
				<%
				if (course_rs.isBeforeFirst())
				{
					while(course_rs.next()){
						%>
						<option value=<%=course_rs.getString("idinstance")%>><%=course_rs.getString("idcoursenumber")%> - <%=course_rs.getString("year")%> <%=course_rs.getString("season")%></option>
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
<!-- HTML Body End -->
<%

if (conn != null)
	conn.close();
%>

</html>