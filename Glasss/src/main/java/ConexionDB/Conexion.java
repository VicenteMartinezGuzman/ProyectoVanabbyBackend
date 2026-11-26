/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package ConexionDB;


import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import io.github.cdimascio.dotenv.Dotenv;
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

    private static final Dotenv dotenv = Dotenv.configure()
            .ignoreIfMissing()
            .load();

    private static final String URL = obtenerVariable("DB_URL");
    private static final String USER = obtenerVariable("DB_USER");
    private static final String PASSWORD = obtenerVariable("DB_PASSWORD");
    private static final String SCHEMA = obtenerVariable("DB_SCHEMA");

    private static final HikariDataSource dataSource;

    private static String obtenerVariable(String nombre) {
        String valor = dotenv.get(nombre);
        if (valor == null || valor.isBlank()) {
            throw new IllegalStateException("Falta configurar la variable " + nombre + " en el archivo .env o en las variables de entorno.");
        }
        return valor;
    }

    static {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(URL);
        config.setUsername(USER);
        config.setPassword(PASSWORD);
        config.setDriverClassName("org.postgresql.Driver");
        config.setSchema(SCHEMA);

        // Configuración del Pool de conexiones
        config.setMaximumPoolSize(10);      // Máximo 10 conexiones activas al mismo tiempo
        config.setMinimumIdle(2);           // Mínimo 2 conexiones listas en espera
        config.setIdleTimeout(30000);       // Libera conexiones inactivas tras 30 segundos
        config.setConnectionTimeout(10000); // Tiempo máximo de espera (10s) si el pool está lleno

        dataSource = new HikariDataSource(config);
    }

    //ESTE CODIGO FUE UNA PRUEBA PARA VER SI PODIA ACCEDER A LAS TABLAS
    public static void main(String[] args) {
        String sql = "SELECT * FROM rol;";

        try (Connection rama = getConexion();
             PreparedStatement ps = rama.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            System.out.println("--- Resultados de la consulta ---");

            while (rs.next()) {
                int id = rs.getInt("rol_id");
                String nombre = rs.getString("nombre_rol");
                String descripcion = rs.getString("descripcion");

                System.out.println("ID: " + id + " | Nombre: " + nombre + " | Descripcion: " + descripcion);
            }

        } catch (SQLException e) {
            System.err.println("Error al ejecutar la consulta: " + e.getMessage());
        }
    }

    public static Connection getConexion() throws SQLException {
        return dataSource.getConnection();
    }

    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    public static void cerrarPool() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }
}