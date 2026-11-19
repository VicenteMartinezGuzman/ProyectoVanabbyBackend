/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Dao;

import ConexionDB.Conexion;
import Modelos.Bloqueo;
import Modelos.Permiso;
import Modelos.Rol;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author vicen
 */
public class SeguridadDAO {

    public List<Rol> listarRoles() {
        List<Rol> lista = new ArrayList<>();
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM rol ORDER BY rol_id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Rol r = new Rol();
                r.setRolId(rs.getInt("rol_id"));
                r.setNombreRol(rs.getString("nombre_rol"));
                r.setDescripcion(rs.getString("descripcion"));
                lista.add(r);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public List<Permiso> listarPermisosPorRol(int rolId) {
        List<Permiso> lista = new ArrayList<>();
        String sql = "SELECT p.* FROM permiso p INNER JOIN rol_permiso rp ON p.permiso_id = rp.permiso_id WHERE rp.rol_id = ?";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, rolId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Permiso p = new Permiso();
                    p.setPermisoId(rs.getInt("permiso_id"));
                    p.setNombrePermiso(rs.getString("nombre_permiso"));
                    p.setDescripcion(rs.getString("descripcion"));
                    lista.add(p);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public boolean asignarPermisoARol(int rolId, int permisoId) {
        String sql = "INSERT INTO rol_permiso (rol_id, permiso_id) VALUES (?, ?)";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, rolId);
            ps.setInt(2, permisoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean registrarBloqueo(Bloqueo b) {
        String sql = "INSERT INTO bloqueo (empleado_id, cliente_id, fecha_bloqueo, intentos_acumulados, motivo) VALUES (?, ?, NOW(), ?, ?)";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setObject(1, b.getEmpleadoId(), Types.INTEGER);
            ps.setObject(2, b.getClienteId(), Types.INTEGER);
            ps.setInt(3, b.getIntentosAcumulados());
            ps.setString(4, b.getMotivo());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
}
