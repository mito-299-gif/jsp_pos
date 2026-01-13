  <%
            double totalRevenue = 0;
            int totalExports = 0;
            int totalQuantity = 0;
            
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                    "root", "Admin"
                );
                
                StringBuilder sql = new StringBuilder(
                    "SELECT COUNT(*) as count, SUM(quantity) as qty, SUM(total_price) as revenue " +
                    "FROM exports WHERE user_id = ? "
                );
                
                if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                    sql.append("AND DATE(export_date) BETWEEN ? AND ? ");
                }
                
                ps = conn.prepareStatement(sql.toString());
                ps.setInt(1, userId);
                
                if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                    ps.setString(2, dateFrom);
                    ps.setString(3, dateTo);
                }
                
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    totalExports = rs.getInt("count");
                    totalQuantity = rs.getInt("qty");
                    totalRevenue = rs.getDouble("revenue");
                }
                
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
            %>