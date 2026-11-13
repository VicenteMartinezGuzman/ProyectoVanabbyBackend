/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package ConexionDB;


import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 *
 * @author vicen
 */
public class Conexion {
    // Configura los datos de tu base de datos local o remota
    private static final String USER = "postgres";
    private static final String PASSWORD = "Holamundo01#";
    
    /*public static void main(String[] args) {
        // Reemplaza "usuarios" por el nombre real de tu tabla dentro del esquema
        String sql = "SELECT * FROM rol;";

        // try-with-resources cierra automáticamente Connection, PreparedStatement y ResultSet
        try (Connection rama = getConexion();
             PreparedStatement ps = rama.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            System.out.println("--- Resultados de la consulta ---");
            
            // rs.next() avanza fila por fila mientras haya registros
            while (rs.next()) {
                // Obtén los datos por el nombre exacto de la columna en PostgreSQL (o por índice 1, 2, 3...)
                int id = rs.getInt("rol_id"); 
                String nombre = rs.getString("nombre_rol");
                String descripcion = rs.getString("descripcion");
                
                System.out.println("ID: " + id + " | Nombre: " + nombre+" | Descripcion: "+ descripcion);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al ejecutar la consulta: " + e.getMessage());
        }
    }*/
    
    public static Connection getConexion() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
            Connection cn = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5433/postgres", 
                USER, 
                PASSWORD
            );
            // setSchema() sí respeta las mayúsculas de vanabbyDB
            cn.setSchema("vanabbyDB"); 
            return cn;
        } catch (ClassNotFoundException e) {
            throw new SQLException("No se encontró el driver de PostgreSQL en el proyecto", e);
        }
    }
}