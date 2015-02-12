<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
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

System.out.println(idcourse);

%>

<body>

</body>
</html>