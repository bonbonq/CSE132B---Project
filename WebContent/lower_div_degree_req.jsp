<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Degree Req - Lower Div</title>
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
/* ============= */
/* Update Action */
/* ============= */
if(action!=null && action.equals("insert")){
	
	PreparedStatement update = conn.prepareStatement(	
			"INSERT INTO lower_division (iddegree, units, gpa) " +
			"SELECT ?,?,?");
	update.setInt(1, Integer.parseInt(request.getParameter("iddegree")));
	update.setInt(2, Integer.parseInt(request.getParameter("units")));
	update.setDouble(3, Double.parseDouble(request.getParameter("gpa")));
	
	if (update.executeUpdate()==1) {
		%>
		<h1>Successfully Inserted!</h1>
		<%
	}
	else {
		%>
		<h1>Insert has failed!</h1>
		<%
	}
}

/* =========================== */
/* Generate Form Fields Action */
/* =========================== */

ResultSet degree_rs = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	int current_year = Calendar.getInstance().get(Calendar.YEAR);
	PreparedStatement course_stmt = conn.prepareStatement("SELECT * FROM degree", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
	/* The below two statements are not closed, this might cause issues later... */
	degree_rs = course_stmt.executeQuery();

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
<body>
	<a href='index.jsp'><button>Home</button></a>
	<h2>Degree Req - Lower Div Form</h2>
	
	<!-- Student Insertion Form -->
	<form action="lower_div_degree_req.jsp" method="POST">
		
		<div>
			Degree:
			<select name="iddegree">
				<%
				if (degree_rs.isBeforeFirst())
				{
					while(degree_rs.next()){
						%>
						<option value=<%=degree_rs.getString("iddegree")%>><%=degree_rs.getString("name")%> - <%=degree_rs.getString("type")%></option>
						<%
					}
				}
				%>
			</select>
		</div>
		<p>
		
		<div>
			Units: <input type="number" name="units" required>
			<br>
		</div>
		<p>
		
		<div>
			GPA: <input type="text" name="gpa" required>
			<br>
		</div>
		<p>
		
		<button type="submit" name="action" value="insert">Submit</button>
		
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