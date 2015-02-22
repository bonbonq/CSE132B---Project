<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MS Req</title>
</head>
</head>
<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.sql.*" %>
<%@page import="org.postgresql.*" %>

<!-- =============== -->
<!-- Java Part Start -->
<!-- =============== -->

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
PreparedStatement pstmt6 = null;

try {
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost/CSE132B?");
	
} catch (Exception e) {
	e.printStackTrace();
	out.println("<h1>org.postgresql.Driver Not Found</h1>");
}

String action = request.getParameter("action");

/* ================== */
/* SUBMIT FORM ACTION */
/* ================== */
ResultSet result_rs = null;
ResultSet result_rs_degree = null;
ResultSet result_rs_lower = null;
ResultSet result_rs_upper = null;
int total_units = 0;
int lower_units = 0;
int upper_units = 0;
if (action!=null && action.equals("submit")) {

	//The following will always run regardless of action
	try{
		conn.setAutoCommit(false);
		pstmt1 = conn.prepareStatement(
				"SELECT * FROM student_instance NATURAL JOIN quarter_course_class__instance NATURAL JOIN course NATURAL JOIN course_coursenumber NATURAL JOIN coursenumber WHERE  idstudent=?;",
				ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
		pstmt1.setInt(1, Integer.parseInt(request.getParameter("ss_num")));
		
		pstmt4 = conn.prepareStatement(
				"SELECT * FROM department_degree AS dd,degree, department WHERE degree.iddegree=dd.iddegree AND department.iddepartment=dd.iddepartment AND degree.iddegree=?",
				ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
		pstmt4.setInt(1, Integer.parseInt(request.getParameter("degree_name")));
		
		pstmt5 = conn.prepareStatement(
				"SELECT * FROM lower_division WHERE iddegree=?;",
				ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
		pstmt5.setInt(1, Integer.parseInt(request.getParameter("degree_name")));
		
		pstmt6 = conn.prepareStatement(
				"SELECT * FROM upper_division WHERE iddegree=?;",
				ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
		pstmt6.setInt(1, Integer.parseInt(request.getParameter("degree_name")));
		
		result_rs = pstmt1.executeQuery();
		result_rs_degree = pstmt4.executeQuery();
		result_rs_lower = pstmt5.executeQuery();
		result_rs_upper = pstmt6.executeQuery();

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
	String abbr = "";
	if (result_rs_degree!=null) {
  		if (result_rs_degree.isBeforeFirst()) {
			while(result_rs_degree.next()) { 
				total_units = result_rs_degree.getInt("total_units");
				abbr = result_rs_degree.getString("abbr");
			}
		}	
  	}
	if (result_rs_lower!=null) {
  		if (result_rs_lower.isBeforeFirst()) {
			while(result_rs_lower.next()) { 
				lower_units = result_rs_lower.getInt("units");
			}
		}	
  	}
	if (result_rs_upper!=null) {
  		if (result_rs_upper.isBeforeFirst()) {
			while(result_rs_upper.next()) { 
				upper_units = result_rs_upper.getInt("units");
			}
		}	
  	}
	
	if (result_rs!=null) {
  		if (result_rs.isBeforeFirst()) {
			while(result_rs.next()) { 
				int units = result_rs.getInt("units");
				String course_number = result_rs.getString("number").split(" ")[1];
				String dept = result_rs.getString("number").split(" ")[0].trim();
				course_number = course_number.replaceAll("[^\\d.]", ""); //Remove non numeric
				
				if(abbr.equals(dept)){
					total_units -= units;
					// lower division
					if (Integer.parseInt(course_number) < 100) {
						lower_units -= units;
					}
					// upper division
					else{
						upper_units -= units;
					}
					if (total_units<0)
						total_units=0;
					if (lower_units<0)
						lower_units=0;
					if (upper_units<0)
						upper_units=0;
				}
				
			}
		}	
  	}
}

/* =========================== */
/* Generate Form Fields Action */
/* =========================== */

ResultSet form_rs = null;
ResultSet form_rs_degree = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	int current_year = Calendar.getInstance().get(Calendar.YEAR);
	pstmt2 = conn.prepareStatement(
			"SELECT * FROM ms NATURAL JOIN student NATURAL JOIN student_quarter__attends WHERE idquarter=2 AND ms.idstudent=student.idstudent AND student_quarter__attends.idstudent=student.idstudent;",
			ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
	pstmt3 = conn.prepareStatement(
			"SELECT * FROM concentration, degree WHERE degree.type='MS' AND concentration.iddegree=degree.iddegree",
			ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
	/* The below two statements are not closed, this might cause issues later... */
	form_rs = pstmt2.executeQuery();
	form_rs_degree = pstmt3.executeQuery();

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


<!-- =============== -->
<!-- HTML Body Start -->
<!-- =============== -->

<body>
	
	<a href='index.jsp'><button>Home</button></a>
	<h2>Student's Current Class Listing</h2>
	
	<!-- Student Insertion Form -->
	<form action="bs_remaining_req.jsp" method="POST">
		
		<div>
			Student:
			<select name="ss_num">
				<%
				if (form_rs.isBeforeFirst())
				{
					while(form_rs.next()){
						%>
						<option value=<%=form_rs.getString("idstudent")%>> <%=form_rs.getString("first_name")%> <%=form_rs.getString("middle_name").equals("NULL")? " " : form_rs.getString("middle_name")%> <%=form_rs.getString("last_name")%> - <%=form_rs.getString("ss_num")%></option>
						<%
					}
				}
				%>
			</select>
		</div>
		<p>
		
		<div>
			Degree:
			<select name="degree_name">
				<%
				if (form_rs_degree.isBeforeFirst())
				{
					while(form_rs_degree.next()){
						%>
						<option value=<%=form_rs_degree.getString("idconcentration")%>> <%=form_rs_degree.getString(8)%> - <%=form_rs_degree.getString("name")%></option>
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
	
	<!-- Edit Form -->
	<h2>Results:</h2>
	<h3>Total Units Left:<%=total_units %></h3>
	<h3>Lower Division Units Left: <%=lower_units %></h3>
	<h3>Upper Division Units Left:<%=upper_units %></h3>
	
	
</body>
<!-- =============== -->
<!-- HTML Body End -->
<!-- =============== -->

<%

if (conn != null)
	conn.close();
if (pstmt1!=null)
	pstmt1.close();
if (pstmt2!=null)
	pstmt2.close();
if (pstmt3!=null)
	pstmt3.close();
if (pstmt4!=null)
	pstmt4.close();
if (pstmt5!=null)
	pstmt5.close();
if (pstmt6!=null)
	pstmt6.close();
%>

</html>