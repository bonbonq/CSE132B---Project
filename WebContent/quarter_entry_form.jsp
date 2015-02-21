<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Quarter Entry Form</title>
</head>
<body>
	<h1>Quarter Entry Form</h1>
	<a href="index.jsp"><button>Home</button></a>
	<%
	String action = request.getParameter("action");
	if (action != null && action.equals("qinsert"))
	{
		String syearString = request.getParameter("syear");
		String eyearString = request.getParameter("eyear");
		
		if (syearString == null || syearString.equals(""))
		{
			%>
			<h3>Error: Please provide a starting year</h3>
			<%
		}
		else
		{
			int syear = Integer.parseInt(request.getParameter("syear"));
			int eyear;
			if (eyearString == null || eyearString.equals(""))
				eyear = syear;
			else
				eyear = Integer.parseInt(eyearString);
			
			Connection conn = null;
			PreparedStatement ps1 = null;
			ResultSet rs1 = null;
			String sql1 = null;
			
			PreparedStatement ps2 = null;
			ResultSet rs2 = null;
			String sql2 = null;
		
			try
			{
				Class.forName("org.postgresql.Driver");
				conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
				conn.setAutoCommit(false);
			
				String [] quarterNames = {"Winter", "Spring", "Summer", "Fall"};
				sql2 = "SELECT DISTINCT year FROM quarter ORDER BY year";
				ps2 = conn.prepareStatement(sql2);
				rs2 = ps2.executeQuery();
				ArrayList<Integer> years = new ArrayList<Integer>();
				
				while (rs2.next())
					years.add(rs2.getInt("year"));
			
				for (int cyear = syear; cyear <= eyear; cyear++)
				{
					if (years.contains(cyear))
						continue;
					for (int i = 0; i < 4; i++)
					{
						sql1 = "INSERT INTO quarter (year, season, quarter_number) VALUES (?, ?, ?)";
						ps1 = conn.prepareStatement(sql1);
						ps1.setInt(1, syear);
						ps1.setString(2, quarterNames[i]);
						ps1.setInt(3, i + 1);
						ps1.executeUpdate();
						ps1.close();
					}
					cyear++;
				}
				conn.commit();
				%>
				<h3>Fall, Winter, Spring, and Summer Quarters added for year(s) <%=syear%>-<%=eyear%></h3>
				<%
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
				if (conn != null)
					conn.close();
			}
		}
	}
	%>
	<form action="quarter_entry_form.jsp">
		<label for="syear">Start Year</label>
		<input type="text" name="syear">
		<label for="eyear">End Year</label>
		<input type="text" name="eyear">
		<input type="hidden" name="action" value="qinsert">
		<input type="submit">
	</form>
</body>
</html>