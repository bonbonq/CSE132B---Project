<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>High Grade</title>
</head>
<body>

<%
Connection conn = null;
PreparedStatement ps0 = null;
PreparedStatement ps1 = null;
PreparedStatement ps2 = null;
PreparedStatement ps3 = null;
PreparedStatement ps4 = null;
PreparedStatement ps5 = null;
ResultSet rs0 = null;
ResultSet rs1 = null;
ResultSet rs2 = null;
ResultSet rs3 = null;
ResultSet rs4 = null;
ResultSet rs5 = null;
String sql0 = null;
String sql1 = null;
String sql2 = null;
String sql3 = null;
String sql4 = null;
String sql5 = null;

try
{
	//Establish DB connection
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
	conn.setAutoCommit(false);
	
	//Get action and hidden parameters
	String action = request.getParameter("action");
	String []hiddens = new String[4];
	hiddens[0] = request.getParameter("faculty");
	hiddens[1] = request.getParameter("course");
	hiddens[2] = request.getParameter("season");
	hiddens[3] = request.getParameter("year");
	
	String filters = "";
	
	for (int i = 0; i < 4; i++)
	{
		if (hiddens[i] != null && !(hiddens[i].equals("None")))
			filters += "1";	
		else
			filters += "0";
	}
	
	%><h1>Grade Distributions</h1><%

	if (action != null && action.equals("display"))
	{
		if (filters.indexOf("1") == -1)
		{
			%>
			<h3>Error: Please provide at least one filter</h3>
			<%
		}
		else
		{
		//Create SQL statement based on selections from UI
		String [] categories = {"faculty_name", "idcourse", "season", "year"};
		String [] category_names = {"Faculty Name", "Course ID", "Quarter", "Year"};
		String category = "";
		String data = "";
		String addition = "";
		int count = 0;
		for (int i = 0; i < 4; i++)
		{
			if ((filters.substring(i, i + 1)).equals("1"))
			{
				addition += " AND ";
				addition += categories[i];
				addition += " = ? ";
				category = category_names[i];
				data = hiddens[i] + "";
				count++;
				%>
					<h2><%=category%>: <%=data%></h2>
				<%
			}
		
		}
		
		sql5 = "SELECT AVG(number_grade) AS gpa" + 
				" FROM grade_conversion, quarter, quarter_course_class__instance, faculty_class_section, student_instance" +
				" WHERE quarter.idquarter = quarter_course_class__instance.idquarter" + 
				" AND quarter_course_class__instance.idclass = faculty_class_section.idclass" + 
				" AND student_instance.idinstance = quarter_course_class__instance.idquarter" + 
				" AND student_instance.grade = grade_conversion.grade" + 
				addition;
		ps5 = conn.prepareStatement(sql5);
		
		sql0 = "SELECT grade, COUNT(*) AS received" + 
		" FROM quarter, quarter_course_class__instance, faculty_class_section, student_instance" +
		" WHERE quarter.idquarter = quarter_course_class__instance.idquarter" + 
		" AND quarter_course_class__instance.idclass = faculty_class_section.idclass" + 
		" AND student_instance.idinstance = quarter_course_class__instance.idquarter" + 
		addition + 
		" GROUP BY student_instance.grade " + 
		" ORDER BY student_instance.grade";
		
		System.out.println(sql0);
		ps0 = conn.prepareStatement(sql0);
		
		//Set given arguments
		int index = 1;
		System.out.println(filters);
		for (int i = 0; i < 4; i++)
		{
			if ((filters.substring(i, i + 1)).equals("1"))
			{
				if (i == 1 || i == 3)
				{
					ps0.setInt(index, Integer.parseInt(hiddens[i]));
					ps5.setInt(index, Integer.parseInt(hiddens[i]));
				}
				else
				{
					ps0.setString(index, hiddens[i]);
					ps5.setString(index, hiddens[i]);
				}
				index++;
			}
		}
		
		//Execute statement and present
		rs0 = ps0.executeQuery();
		rs5 = ps5.executeQuery();
		
		
		if (rs5.isBeforeFirst())
		{
			System.out.println("inside");
			rs5.next();
			double gpa = rs5.getDouble("gpa");
			%><h2>Grade Point Average: <%=gpa%></h2>
			<table>
		<tr>
			<th>Grade</th>
			<th>Received</th>
		</tr>
		<%
		String grade = null;
		int received = 0;
		while (rs0.next())
		{
			grade = rs0.getString("grade");
			received = rs0.getInt("received");
			%>
			<tr>
				<td><%=grade%></td>
				<td><%=received%></td>
			</tr>
			<%
		}
		%>
		</table>
		<%
		}
		else
			%><h2>No GPA or grades to report</h2><%
		}
	}
		sql1 = "SELECT faculty_name FROM faculty";
		ps1 = conn.prepareStatement(sql1);
		rs1 = ps1.executeQuery();
		
		sql2 = "SELECT * FROM course";
		ps2 = conn.prepareStatement(sql2);
		rs2 = ps2.executeQuery();
		
		sql3 = "SELECT DISTINCT season FROM quarter";
		ps3 = conn.prepareStatement(sql3);
		rs3 = ps3.executeQuery();
		
		sql4 = "SELECT DISTINCT year FROM quarter";
		ps4 = conn.prepareStatement(sql4);
		rs4 = ps4.executeQuery();
		
		%>
		<form action="high_grade.jsp" method="POST">
			Faculty:
			<select name="faculty">
				<option>None</option>
				
			<% 
				String faculty;
				while (rs1.next())
				{
					faculty = rs1.getString("faculty_name");
					%><option><%=faculty%></option><%
				}
			%>
			</select>
			Course ID:
			<select name="course">
				<option>None</option>
			<%
				int course;
				while (rs2.next())
				{
					course = rs2.getInt("idcourse");
					%><option><%=course%></option><%
				}
			
			%>
			</select>
			Quarter:
			<select name="season">
				<option>None</option>
			
			<% 
				String season;
				while (rs3.next())
				{
					season = rs3.getString("season");
					%><option><%=season%></option><%
				}
			%>
			</select>
			Year:
			<select name="year">
				<option>None</option>
			
			<%
				int year;
				while (rs4.next())
				{
					year = rs4.getInt("year");
					%><option><%=year%></option><%
				}
			%>
			
			</select>
			
			<input type="hidden" name="action" value="display">
			<input type="submit">
		</form>
		<br>
		<br>
		<form action="index.jsp">
			<input type="submit" value="Back To Index">
		</form>
		<%
	
}

catch (SQLException e)
{
	conn.rollback();
	e.printStackTrace();
}

finally
{
	if (ps0 != null)
		ps0.close();
	if (ps1 != null)
		ps1.close();
	if (ps2 != null)
		ps2.close();
	if (ps3 != null)
		ps3.close();
	if (ps4 != null)
		ps4.close();
	if (ps5 != null)
		ps5.close();
	if (rs0 != null)
		rs0.close();
	if (rs1 != null)
		rs1.close();
	if (rs2 != null)
		rs2.close();
	if (rs3 != null)
		rs3.close();
	if (rs4 != null)
		rs4.close();
	if (rs5 != null)
		rs5.close();
	if (conn != null)
	{
		conn.setAutoCommit(false);
		conn.close();
	}
}
%>

</body>
</html>