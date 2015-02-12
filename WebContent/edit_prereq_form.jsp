<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.sql.*" %>
<%@page import="org.postgresql.*" %>
<!-- Java Part start -->
<%
boolean debug = false;

boolean success = false;
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

/* Create DB connection */
Connection conn = null;

try {
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost/CSE132B?");
	
} catch (Exception e) {
	e.printStackTrace();
	out.println("<h1>org.postgresql.Driver Not Found</h1>");
}

/* =============================== */
/* Continue from course_entry_form */
/* =============================== */
String action = request.getParameter("action");
int idcourse = 0;
if (action!=null && action.equals("course_entry_form")) {
	idcourse = Integer.parseInt(request.getParameter("idcourse"));
	if (idcourse==0)
		response.sendRedirect("course_entry_form.jsp");
}
else {
	response.sendRedirect("course_entry_form.jsp");
}


/* ========================= */
/* EDIT FORM DATA GENERATION */
/* ========================= */

ResultSet rs = null;
ResultSet courses = null;
boolean consent = false;
HashSet<Integer> selected = new HashSet<Integer>();
//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	/* The below statements are not closed, this might cause issues later... */
	PreparedStatement rs1 = conn.prepareStatement("SELECT prereq_idcourse, number FROM prereqs, course_coursenumber, coursenumber WHERE prereqs.idcourse=? AND prereqs.idcourse=course_coursenumber.idcourse AND course_coursenumber.idcoursenumber=coursenumber.idcoursenumber", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
	rs1.setInt(1, idcourse);
	PreparedStatement rs2 = conn.prepareStatement("SELECT DISTINCT * FROM course NATURAL JOIN course_coursenumber NATURAL JOIN coursenumber", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
	PreparedStatement rs3 = conn.prepareStatement("SELECT * FROM course WHERE idcourse=?", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
	rs3.setInt(1, idcourse);
	
	rs = rs1.executeQuery();
	courses = rs2.executeQuery();
	ResultSet approval_rs = rs3.executeQuery();
	approval_rs.next();
	consent = approval_rs.getBoolean("consent_prereq");
	
	if (rs.isBeforeFirst()) {
		while(rs.next()) {
			selected.add(rs.getInt("prereq_idcourse"));
		}
	}
	
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

<!-- Edit Form -->
	<h2>Edit Prerequisites Form</h2>
	
	<form action="course_entry_form.jsp" method="POST">
		<br>
		<input type="hidden" name="idcourse" value="<%=idcourse %>">
		<input type="checkbox" name="prereq" value=0  <%=consent ? "checked" : "" %>  > Consent of Instructor
		<%
		if (courses.isBeforeFirst())
		{
			while(courses.next()){
				%>
				<br>
				<input type="checkbox" name="prereq" value=<%=courses.getInt("idcourse")%> <%=selected.remove(courses.getInt("idcourse")) ? "checked" : "" %>> <%=courses.getString("number")%>
				<%
			}
		}
		%>
		<p>
		<button type="submit" name="action" value="prereq_update">Submit</button> 
		<a href='course_entry_form.jsp'><button>Back</button></a>
		<p>
	</form>

</body>
<!-- HTML Body End -->

<%

if (conn != null)
	conn.close();
%>
</html>