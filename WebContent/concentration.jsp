<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
        <%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<%

Connection conn = null;

String sql1 = null;
PreparedStatement ps1 = null;
ResultSet rs1 = null;

String sql2 = null;
PreparedStatement ps2 = null;
ResultSet rs2 = null;

String sql3 = null;
PreparedStatement ps3 = null;
ResultSet rs3 = null;

String sql4 = null;
PreparedStatement ps4 = null;
ResultSet rs4 = null;

String action = request.getParameter("action");

ArrayList<String> degree_names = new ArrayList<String>();
ArrayList<Integer> degree_ids = new ArrayList<Integer>();
ArrayList<Integer> course_ids = new ArrayList<Integer>();
HashMap<Integer,String> course_numbers = new HashMap<Integer,String>();
HashMap<Integer,Double> gpas = new HashMap<Integer,Double>();
HashMap<Integer, ArrayList<String>> concentration_courses = new HashMap<Integer, ArrayList<String>>();

ArrayList<String> concentration_names = new ArrayList<String>();
ArrayList<Integer> concentration_ids = new ArrayList<Integer>();

try
{
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
	conn.setAutoCommit(false);
	
	if (action != null && action.equals("view"))
	{
		sql1 = "SELECT degree.iddegree, degree.name AS dn, idconcentration, concentration.name AS cn, gpa " +
	 	" FROM degree, concentration " + 
		" WHERE degree.iddegree = concentration.iddegree";
		ps1 = conn.prepareStatement(sql1);
		rs1 = ps1.executeQuery();
		
		while (rs1.next())
		{
			System.out.println("inside");
			degree_names.add(rs1.getString("dn"));
			degree_ids.add(rs1.getInt("iddegree"));
			concentration_ids.add(rs1.getInt("idconcentration"));
			concentration_names.add(rs1.getString("cn"));
			if (rs1.getDouble("gpa") == 0)
				gpas.put(rs1.getInt("idconcentration"), rs1.getDouble("gpa"));
		}
		
		
		sql2 = "SELECT idconcentration, concentration_course.idcourse, number " +
		" FROM concentration_course, course_coursenumber, coursenumber" +
		" WHERE course_coursenumber.idcoursenumber = coursenumber.idcoursenumber " + 
		" AND concentration_course.idcourse = course_coursenumber.idcourse" +
		" ORDER BY idconcentration, idcourse";
		ps2 = conn.prepareStatement(sql2);
		rs2 = ps2.executeQuery();
		
		int prev = -1;
		int curr = -1;
		
		int prev_id = -1;
		String cnumber_string = "";
		
		ArrayList<String> list = new ArrayList<String>();
		while (rs2.next())
		{
			System.out.println(rs2.getInt("idcourse"));
			if (prev_id == rs2.getInt("idcourse") && prev == rs2.getInt("idconcentration"))
			{
				cnumber_string += " / ";
				cnumber_string += rs2.getString("number");
			}
			else if (prev == rs2.getInt("idconcentration"))
			{
				System.out.println(rs2.getInt("idconcentration"));
				list.add(cnumber_string);
				cnumber_string = rs2.getString("number");
			}
			else
			{
				if (prev_id != -1)
				{
					concentration_courses.put(prev, list);
					list = new ArrayList<String>();
				}
				cnumber_string += rs2.getString("number");
				prev_id = rs2.getInt("idcourse");
				prev = rs2.getInt("idconcentration");
			}
		}
		concentration_courses.put(prev, list);		
	}
	else if (action != null && action.equals("update"))
	{
		String [] courses = request.getParameterValues("courses");
		if (courses == null)
			response.sendRedirect("concentration.jsp");
		double x;
		if (request.getParameter("gpa") != null)
		{
			try
			{
				x = Double.parseDouble(request.getParameter("gpa"));
			}
			catch (NumberFormatException e)
			{
				session.setAttribute("error", "gpa");
				response.sendRedirect("concentration.jsp");
			}
		}
		HashSet<Integer> course_ids_1 = new HashSet<Integer>();
		HashSet<Integer> course_ids_2 = new HashSet<Integer>();
		HashSet<Integer> course_ids_3 = new HashSet<Integer>();

		System.out.println(request.getParameter("idconcentration"));
		int idconcentration = Integer.parseInt(request.getParameter("idconcentration"));
		String concentration_name = request.getParameter("cname");
		sql1 = "SELECT idcourse FROM concentration_course WHERE idconcentration = ?";
		ps1 = conn.prepareStatement(sql1);
		ps1.setInt(1, idconcentration);
		rs1 = ps1.executeQuery();
		
		sql2 = "UPDATE concentration SET name=? WHERE idconcentration=?";
		ps2 = conn.prepareStatement(sql2);
		ps2.setString(1, concentration_name);
		ps2.setInt(2, idconcentration);
		ps2.executeUpdate();
		
		while (rs1.next())
		{
			course_ids_1.add(rs1.getInt("idcourse"));
		}
		for (int i = 0; i < courses.length; i++)
		{
			course_ids_2.add(Integer.parseInt(courses[i]));
			course_ids_3.add(Integer.parseInt(courses[i]));
		}
		
		course_ids_2.removeAll(course_ids_1);
		course_ids_1.removeAll(course_ids_3);
		
		Iterator<Integer> it_2 = course_ids_2.iterator();
		Iterator<Integer> it_1 = course_ids_1.iterator();
		
		sql3 = "INSERT INTO concentration_course (idconcentration, idcourse) VALUES (?,?)";
		ps3 = conn.prepareStatement(sql3);
		ps3.setInt(1, idconcentration);
		
		sql4 = "DELETE FROM concentration_course WHERE idconcentration = ? AND idcourse = ?";
		ps4  = conn.prepareStatement(sql4);
		ps4.setInt(1, idconcentration);
		
		while (it_2.hasNext())
		{
			ps3.setInt(2, it_2.next());	
			ps3.executeUpdate();
		}
		
		while (it_1.hasNext())
		{
			ps4.setInt(2, it_1.next());
			ps4.executeUpdate();
		}
		conn.commit();
		session.setAttribute("success", "Update");
		response.sendRedirect("concentration.jsp?action=view");
	}
	else if (action != null && action.equals("insert"))
	{
		String [] courses = request.getParameterValues("courses");
		System.out.println(courses);
		if (courses == null)
		{
			response.sendRedirect("concentration.jsp");
			return;
		}
		double x;
		if (request.getParameter("gpa") != null)
		{
			try
			{
				x = Double.parseDouble(request.getParameter("gpa"));
			}
			catch (NumberFormatException e)
			{
				System.out.println("encountered error");
				session.setAttribute("error", "gpa");
				response.sendRedirect("concentration.jsp");
				return;
			}
		}
		int degree = Integer.parseInt(request.getParameter("degree"));
		String gpa = request.getParameter("gpa");
		double gpa_double = 0;
		if (gpa != null)
			gpa_double = Double.parseDouble(gpa);
		String cname = request.getParameter("cname");
		//String [] courses = request.getParameterValues("courses");
		if (gpa == null)
			sql1 = "INSERT INTO concentration (iddegree, name) VALUES (?,?) RETURNING idconcentration";
		else
			sql1 = "INSERT INTO concentration (iddegree, name, gpa) VALUES (?,?,?) RETURNING idconcentration";
		ps1 = conn.prepareStatement(sql1);
		ps1.setInt(1, degree);
		ps1.setString(2, cname);
		if (gpa != null)
			ps1.setDouble(3, gpa_double);
		ps1.execute();
		//System.out.println("executed");
		rs1 = ps1.getResultSet();
		rs1.next();
		//System.out.println(rs1.getInt("idconcentration"));
		
		sql2 = "INSERT INTO concentration_course (idconcentration, idcourse) VALUES (?,?)";
		ps2 = conn.prepareStatement(sql2);
		int conc_id = rs1.getInt("idconcentration");
		ps2.setInt(1, conc_id);
		for (int i = 0; i < courses.length; i++)
		{
			ps2.setInt(2, Integer.parseInt(courses[i]));
			ps2.executeUpdate();
		}
		conn.commit();
		session.setAttribute("success", "Insert");
		response.sendRedirect("concentration.jsp?action=view");
	}
	else if (action != null && action.equals("delete"))
	{
		System.out.println(request.getParameter("idconcentration"));
		int idconcentration = Integer.parseInt(request.getParameter("idconcentration"));
		sql1 = "DELETE FROM concentration WHERE idconcentration = ?";
		ps1 = conn.prepareStatement(sql1);
		ps1.setInt(1, idconcentration);
		ps1.executeUpdate();
		conn.commit();
		session.setAttribute("success", "Delete");
		response.sendRedirect("concentration.jsp?action=view");
	}
	else
	{
		sql1 = "SELECT iddegree, name FROM degree";
		ps1 = conn.prepareStatement(sql1);
		rs1 = ps1.executeQuery();
		
		while (rs1.next())
		{
			degree_names.add(rs1.getString("name"));
			degree_ids.add(rs1.getInt("iddegree"));
		}
		
		sql2 = "SELECT idcourse, number FROM course_coursenumber, coursenumber" + 
		" WHERE course_coursenumber.idcourse_coursenumber = coursenumber.idcoursenumber" +
		" ORDER BY idcourse";
		ps2 = conn.prepareStatement(sql2);
		rs2 = ps2.executeQuery();
		
		int prev_id = -1;
		int prev_number = -1;
		String cnumber_string = "";
		
		while (rs2.next())
		{
			if (prev_id == rs2.getInt("idcourse"))
			{
				cnumber_string += " / ";
				cnumber_string += rs2.getString("number");
			}
			else
			{
				if (prev_id != -1)
					course_numbers.put(prev_id, cnumber_string);
				course_ids.add(rs2.getInt("idcourse"));
				cnumber_string = rs2.getString("number");
				prev_id = rs2.getInt("idcourse");
			}
		}
	}
}

catch (SQLException e)
{
	conn.rollback();
	e.printStackTrace();
}

finally
{
	if (ps1 != null)
		ps1.close();
	if (rs1 != null)
		rs1.close();
	if (ps2 != null)
		ps2.close();
	if (rs2 != null)
		rs2.close();
	if (ps3 != null)
		ps3.close();
	if (rs3 != null)
		rs3.close();
	if (ps4 != null)
		ps4.close();
	if (rs4 != null)
		rs4.close();
	if (conn != null)
		conn.close();	
}

%>
</head>
<body>
	<a href="index.jsp"><button>Home</button></a>
	<a href="concentration.jsp"><button>Add Concentration</button></a>
	<a href="concentration.jsp?action=view"><button>View Concentrations</button></a>
	<h1>Concentration Add Form</h1>
	<%
	if (action != null && action.equals("view"))
	{
		
		%>
		<h2>Viewing All Concentrations</h2>
		<%
		String success = request.getParameter("success");
		session.invalidate();
		if (success != null)
		{
			%>
			<h3><%=success%> was successful!</h3>
			<%
		}
		%>
		<table>
			<tr>
				<th>Degree ID</th>
				<th>Degree Name</th>
				<th>Concentration ID</th>
				<th>Concentration Name</th>
				<th>Courses Required</th>
				<th>Minimum GPA</th>
		<%
		String gpa_string = "";
		ArrayList<String> courseList;
		for (int i = 0; i < concentration_ids.size(); i++)
		{
			%>
			<tr>
				<td><%=degree_ids.get(i)%></td>
				<td><%=degree_names.get(i)%></td>
				<td><%=concentration_ids.get(i)%></td>
				<td><%=concentration_names.get(i)%></td>
				<td>
					<ul>
					<%
					courseList = concentration_courses.get(concentration_ids.get(i));
					for (int j = 0; j < courseList.size(); j++)
					{
						%>
						<li><%=courseList.get(j)%></li>
						<%
					}
					%>
					</ul>
				</td>
				<%
				if (gpas.get(concentration_ids.get(i)) != null)
					gpa_string = gpas.get(concentration_ids.get(i)).toString();
				else
					gpa_string = "N/A";
				%>
				<td><%=gpa_string%></td>
				<td>
						<form action="concentration.jsp" method="POST">
							<input type="hidden" name="action" value="delete">
							<input type="hidden" name="idconcentration" value="<%=concentration_ids.get(i)%>">
							<input type="submit" value="Delete">
						</form>
					</td>
					<td>
					<form action="concentration.jsp" method="POST">
						<input type="hidden" name="action" value="updatepre">
						<input type="hidden" name="idconcentration" value="<%=concentration_ids.get(i)%>">
						<input type="hidden" name="iddegree" value="<%=degree_ids.get(i)%>">
						<input type="hidden" name="dname" value="<%=degree_names.get(i)%>">
						<input type="submit" value="Update">
					</form>
				</td>
			</tr>
			<%
		}
		%>
		</table>
		<%
	}
	else
	{
		String error = (String) session.getAttribute("error");
		if (error != null && error.equals("gpa"))
		{
			%>
			<h4>Error: please provide a numeric GPA</h4>
			<%
		}
		session.invalidate();
		%>
		<form action="concentration.jsp" method="POST">
		<%
		String nextAction = null;
		
		if (action != null && action.equals("updatepre"))
		{
			String iddegree = request.getParameter("iddegree");
			String dname = request.getParameter("dname");
			int idconcentration = Integer.parseInt(request.getParameter("idconcentration"));
			%>
			<h3>Degree ID: <%=iddegree%> Degree Name: <%=dname%></h3>
			<input type="hidden" name="idconcentration" value="<%=idconcentration%>">
			
			<%
			nextAction = "update";
		}
		else
		{
			nextAction = "insert";
			%>
			Degree:
			<select name="degree">
			<%
			for (int i = 0; i < degree_ids.size(); i++)
			{
				%>
				<option value="<%=degree_ids.get(i)%>"><%=degree_ids.get(i)%> <%=degree_names.get(i)%></option>
				<%
			}
			%>
			</select><br><br>
		<%
		}
		%>
			Concentration Name:<br>
			<input type="text" name="cname"><br><br>
			Minimum GPA:<br>
			<input type="text" name="gpa"><br><br>
			Courses:<br>
			<%
			for (int i = 0; i < course_ids.size(); i++)
			{
				%>
			<input type="checkbox" name="courses" value="<%=course_ids.get(i)%>"><%=course_numbers.get(course_ids.get(i))%><br>
				<%
			}
			%>
			<input type="hidden" name="action" value="<%=nextAction%>"><br>
			<input type="submit">
		</form>
		<%
	}
	%>
</body>
</html>