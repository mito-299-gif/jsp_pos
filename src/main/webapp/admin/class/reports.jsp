<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%

if (session.getAttribute("userId") == null || !"ADMIN".equals(session.getAttribute("role"))) {
    response.sendRedirect("../index.jsp");
    return;
}


String exportType = request.getParameter("export");
if (exportType != null) {
    String dateFrom = request.getParameter("dateFrom");
    String dateTo = request.getParameter("dateTo");
    
    if ("excel".equals(exportType)) {
        response.setContentType("application/vnd.ms-excel");
        response.setHeader("Content-Disposition", "attachment; filename=export_report_" +
            new SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date()) + ".xls");
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                "root", "Admin"
            );
            
            String sql = "SELECT e.export_code, e.export_date, p.product_code, p.product_name, " +
                        "e.quantity, e.unit_price, e.total_price, u.full_name, e.notes " +
                        "FROM exports e " +
                        "JOIN products p ON e.product_id = p.id " +
                        "JOIN users u ON e.user_id = u.id ";
            
            if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                sql += "WHERE DATE(e.export_date) BETWEEN ? AND ? ";
            }
            
            sql += "ORDER BY e.export_date DESC";
            
            ps = conn.prepareStatement(sql);
            
            if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                ps.setString(1, dateFrom);
                ps.setString(2, dateTo);
            }
            
            rs = ps.executeQuery();
            
    
            out.println("<html><head><meta charset='UTF-8'></head><body>");
            out.println("<table border='1'>");
            out.println("<tr style='background-color: #4CAF50; color: white;'>");
            out.println("<th>ລະຫັດສົງອອກ</th>");
            out.println("<th>ວັນທີ</th>");
            out.println("<th>ລະຫັດສິນຄ້າ</th>");
            out.println("<th>ຊື່ສິນຄ້າ</th>");
            out.println("<th>ຈຳນວນ</th>");
            out.println("<th>ລາຄາ/ໜ່ວຍ</th>");
            out.println("<th>ລາຄາລວມ</th>");
            out.println("<th>ພະນັກງານ</th>");
            out.println("<th>ຫມາຍເຫດ</th>");
            out.println("</tr>");
            
            DecimalFormat df = new DecimalFormat("#,##0");
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            double grandTotal = 0;
            
            while (rs.next()) {
                double total = rs.getDouble("total_price");
                grandTotal += total;
                
                out.println("<tr>");
                out.println("<td>" + rs.getString("export_code") + "</td>");
                out.println("<td>" + sdf.format(rs.getTimestamp("export_date")) + "</td>");
                out.println("<td>" + rs.getString("product_code") + "</td>");
                out.println("<td>" + rs.getString("product_name") + "</td>");
                out.println("<td>" + rs.getInt("quantity") + "</td>");
                out.println("<td>" + df.format(rs.getDouble("unit_price")) + "</td>");
                out.println("<td>" + df.format(total) + "</td>");
                out.println("<td>" + rs.getString("full_name") + "</td>");
                out.println("<td>" + (rs.getString("notes") != null ? rs.getString("notes") : "") + "</td>");
                out.println("</tr>");
            }
            
            out.println("<tr style='background-color: #f0f0f0; font-weight: bold;'>");
            out.println("<td colspan='6'>ລວມທັງໝົດ</td>");
            out.println("<td>" + df.format(grandTotal) + "</td>");
            out.println("<td colspan='2'></td>");
            out.println("</tr>");
            
            out.println("</table>");
            out.println("</body></html>");
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (ps != null) try { ps.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
        
        return;
    }
}

DecimalFormat df = new DecimalFormat("#,##0");
SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");


String dateFrom = request.getParameter("dateFrom");
String dateTo = request.getParameter("dateTo");
String productFilter = request.getParameter("productFilter");
String userFilter = request.getParameter("userFilter");
%>