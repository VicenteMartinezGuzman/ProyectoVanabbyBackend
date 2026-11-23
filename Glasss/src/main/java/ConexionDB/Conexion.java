/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package ConexionDB;


import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
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
    private static final String URL="jdbc:postgresql://localhost:5433/postgres";
    private static final String USER = "postgres";
    private static final String PASSWORD = "Holamundo01#";
    private static final HikariDataSource dataSource;
    
    
    static {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(URL);
        config.setUsername(USER);
        config.setPassword(PASSWORD);
        config.setDriverClassName("org.postgresql.Driver");
        config.setSchema("vanabby");

        // Configuración del Pool de conexiones
        config.setMaximumPoolSize(10);      // Máximo 10 conexiones activas al mismo tiempo
        config.setMinimumIdle(2);           // Mínimo 2 conexiones listas en espera
        config.setIdleTimeout(30000);       // Libera conexiones inactivas tras 30 segundos
        config.setConnectionTimeout(10000); // Tiempo máximo de espera (10s) si el pool está lleno

        dataSource = new HikariDataSource(config);
    }
    
    //ESTE CODIGO FUE UNA PRUEBA PARA VER SI PODIA ACCEDER A LAS TABLAS
    public static void main(String[] args) {
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
    }
    
    public static Connection getConexion() throws SQLException {
       return dataSource.getConnection();
    }

   public static void cerrarPool() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }
}