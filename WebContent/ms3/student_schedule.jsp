<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Student Schedule</title>
<%

//SQL declarations
Connection conn = null;

String sql0 = null;
PreparedStatement ps0 = null;
ResultSet rs0 = null;

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

//Data structures for storing queries
HashMap<String,String> ssn_info = new HashMap<String,String>();
HashSet<String> class_print = new HashSet<String>();

String action = request.getParameter("action");

try
{
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
	conn.setAutoCommit(false);
	
	sql0 = "SELECT ss_num, first_name, middle_name, last_name FROM student";
	ps0 = conn.prepareStatement(sql0);
	rs0 = ps0.executeQuery();
	String student_info;
	String middle_name;
	String blank2;
	
	//Some students don't have middle names: NULL values in database
	while (rs0.next())
	{
		middle_name = rs0.getString("middle_name");
		if (rs0.wasNull())
		{
			blank2 = "";
			middle_name = "";
		}
		else
			blank2 = " ";
		student_info = rs0.getString("ss_num") + " - " + rs0.getString("first_name") + " " + middle_name + blank2 + rs0.getString("last_name");
		ssn_info.put(rs0.getString("ss_num"), student_info);
	}
	
	//After submitting a student's information
	if (action != null && action.equals("list"))
	{
		String current_season = "Winter";
		int current_year = 2015;
		String ss_num = request.getParameter("ss_num");

		sql1 = "SELECT idstudent FROM student WHERE ss_num = ?";
		ps1 = conn.prepareStatement(sql1);
		ps1.setString(1, ss_num);
		rs1 = ps1.executeQuery();
		rs1.next();
		int idstudent = rs1.getInt("idstudent");
	
		sql2 = "SELECT day_of_week, start_time, end_time" +
		" FROM student_section__enrolled, section_weekly, weekly" +
	    " WHERE student_section__enrolled.idstudent = ?" +
	    " AND student_section__enrolled.idsection = section_weekly.idsection" +
	    " AND section_weekly.idweekly = weekly.idweekly";
		ps2 = conn.prepareStatement(sql2);
		ps2.setInt(1, idstudent);
		rs2 = ps2.executeQuery();
	
		sql3 = "SELECT faculty_class_section.idclass, faculty_class_section.idsection, day_of_week, start_time, end_time" + 
	 	" FROM quarter, quarter_course_class__instance, faculty_class_section, section_weekly, weekly, class" +
		" WHERE quarter_course_class__instance.idquarter = quarter.idquarter" +
	 	" AND quarter.season = ?" +
		" AND quarter.year = ?" +
	 	" AND faculty_class_section.idclass = quarter_course_class__instance.idclass" +
		" AND section_weekly.idsection = faculty_class_section.idsection" +
	 	" AND weekly.idweekly = section_weekly.idweekly" +
		" AND class.idclass = quarter_course_class__instance.idclass" +
	 	" ORDER BY idclass, idsection";
		ps3 = conn.prepareStatement(sql3);
		ps3.setString(1, current_season);
		ps3.setInt(2, current_year);
		rs3 = ps3.executeQuery();
	
		String [] days = {"M", "Tu", "W", "Th", "F", "Sa", "Su"};
		ArrayList<Integer> start_times = new ArrayList<Integer>();
		ArrayList<Integer> end_times = new ArrayList<Integer>();
		String day_string;
		int s_hours, s_minutes, e_hours, e_minutes;
		while (rs2.next())
		{
			day_string = rs2.getString("day_of_week");
			s_hours = Integer.parseInt(rs2.getTime("start_time").toString().substring(0,2));
			s_minutes = Integer.parseInt(rs2.getTime("start_time").toString().substring(3,5));
			s_minutes = s_minutes + (s_hours * 60);
		
			e_hours = Integer.parseInt(rs2.getTime("start_time").toString().substring(0,2));
			e_minutes = Integer.parseInt(rs2.getTime("start_time").toString().substring(3,5));
			e_minutes = e_minutes + (e_hours * 60);
		
			for (int i = 0; i < 7; i++)
			{
				if (day_string.indexOf(days[i]) != -1)
				{
					s_minutes = s_minutes + (3600 * i);
					start_times.add(s_minutes);
					e_minutes = e_minutes + (3600 * i);
					end_times.add(e_minutes);
				}
			}
		}
	
		//Sort start and end times to synchronize by index
		Collections.sort(start_times);
		Collections.sort(end_times);
		
		//Generate arrays for binary search of conflicts
		Integer [] start_times_array = new Integer[start_times.size()];
		Integer [] end_times_array = new Integer[end_times.size()];
		start_times.toArray(start_times_array);
		end_times.toArray(end_times_array);
		
		//Reusable variables for each tuple
		int idclass_prev = -1;
		int idsection_prev = -1;
		int idclass = -1;
		int idsection = -1;
		
		//Class data to print
		HashSet<Integer> neg_classes = new HashSet<Integer>();
		
		//Flags
		boolean section_skip = false;
		boolean class_skip = false;
		boolean first = true;
		
		//Sequential search through each class and section of the current quarter (with optimization)
		while (rs3.next())
		{
			if (!first)
			{
				idclass_prev = idclass;
				idsection_prev = idsection;
			}
			
			idclass = rs3.getInt("idclass");
			idsection = rs3.getInt("idsection");
			
			if (!first)
			{
				if (idclass_prev == idclass && class_skip == true)
					continue;
				if (idclass_prev != idclass && class_skip == false)
				{
					System.out.println("4");
					sql4 = "SELECT idcourse, idclass, title" +
							" FROM quarter_course_class__instance, class" +
							" WHERE quarter_course_class__instance.idclass = ?" + 
							" AND quarter_course_class__instance.idclass = class.idclass";
					ps4 = conn.prepareStatement(sql4);
					ps4.setInt(1, idclass_prev);
					rs4 = ps4.executeQuery();
					rs4.next();
					class_print.add("Course ID: " + rs4.getInt("idcourse") + " - " + "Class ID: " + rs4.getInt("idclass") + " " + rs4.getString("title"));
					ps4.close();
					rs4.close();
				}
				if (idsection_prev == idsection && section_skip == true)
					continue;
				if (idsection_prev != idsection && section_skip == false)
				{
					if (idclass_prev == idclass)
					{
						class_skip = true;
						continue;
					}
					else
					{
						System.out.println("4.5");
						sql4 = "SELECT idcourse, idclass, title" +
								" FROM quarter_course_class__instance, class" +
								" WHERE quarter_course_class__instance.idclass = ?" + 
								" AND quarter_course_class__instance.idclass = class.idclass";
						ps4 = conn.prepareStatement(sql4);
						ps4.setInt(1, idclass_prev);
						rs4 = ps4.executeQuery();
						rs4.next();
						class_print.add("Course ID: " + rs4.getInt("idcourse") + " - " + "Class ID: " + rs4.getInt("idclass") + " " + rs4.getString("title"));
						ps4.close();
						rs4.close();
					}
				}
			}
		
			class_skip = false;
			section_skip = false;
			
			day_string = rs3.getString("day_of_week");
			s_hours = Integer.parseInt(rs3.getTime("start_time").toString().substring(0,2));
			s_minutes = Integer.parseInt(rs3.getTime("start_time").toString().substring(3,5));
			s_minutes = s_minutes + (s_hours * 60);
			
			e_hours = Integer.parseInt(rs3.getTime("start_time").toString().substring(0,2));
			e_minutes = Integer.parseInt(rs3.getTime("start_time").toString().substring(3,5));
			e_minutes = e_minutes + (e_hours * 60);
			
			int start_index, end_index, middle_index;
			
			for (int i = 0; i < 7 || section_skip == true; i++)
			{
				if (day_string.indexOf(days[i]) != -1)
				{
					s_minutes = s_minutes + (3600 * i);
					e_minutes = e_minutes + (3600 * i);
					
					start_index = 0;
					end_index = start_times_array.length - 1;
					middle_index = start_index;
					while (start_index < end_index)
					{
						middle_index = (end_index - start_index) / 2;
						if (start_times_array[middle_index] > s_minutes)
						{
							end_index = middle_index - 1;
						}
						else if (start_times_array[middle_index] < s_minutes)
						{
							start_index = middle_index + 1;
						}
						else
						{
							if (s_minutes < end_times_array[middle_index])
							{
								section_skip = true;
								break;
							}
						}
					}
					if (section_skip != true)
					{
						middle_index = (end_index - start_index) / 2;
						if (s_minutes < start_times_array[middle_index])
						{
							if (s_minutes < end_times_array[middle_index - 1] || e_minutes > start_times_array[middle_index])
							{
								section_skip = true;
							}
						}		
					
						else if (s_minutes > start_times_array[middle_index])
						{
							if (s_minutes < end_times_array[middle_index] || e_minutes > start_times_array[middle_index + 1])
							{
								section_skip = true;
							}
						}
						else
						{
							if (s_minutes < end_times_array[middle_index])
							{
								section_skip = true;
							}
						}	
					}
				}		
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
	if (ps0 != null)
		ps0.close();
	if (rs0 != null)
		rs0.close();
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
<h2>Find Conflicting Classes</h2>
Select Student:
<form action="student_schedule.jsp" method="POST">
	<select name="ss_num">
<%
Set<String> ssn_keys = ssn_info.keySet();
Iterator<String> it_ssn = ssn_keys.iterator();
String curr_key;
while (it_ssn.hasNext())
{
	curr_key = it_ssn.next();
%>
		<option value="<%=curr_key%>"><%=ssn_info.get(curr_key)%></option>
<%
}
%>
	</select>
	<input type="hidden" name="action" value="list">
	<input type="submit">
</form>
<%
if (action != null && action.equals("list"))
{
%>
	Conflicting classes:
	<ul>
	<%
	Iterator<String> it_print = class_print.iterator();
	while (it_print.hasNext())
	{
		%>
		<li><%=it_print.next()%></li>
		<%	
	}
	%>
	</ul>
<%	
}
%>
</body>
</html>