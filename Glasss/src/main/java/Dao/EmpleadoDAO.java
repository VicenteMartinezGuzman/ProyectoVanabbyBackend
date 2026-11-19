/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Dao;

import ConexionDB.Conexion;
import Modelos.Empleado;
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
public class EmpleadoDAO {

    public List<Empleado> listar() {
        List<Empleado> lista = new ArrayList<>();
        String sql = "SELECT empleado_id, nombre_usuario, nombre, ap_paterno, ap_materno, rol_id, bloqueado, intentos_fallidos, ultimo_intento, creado_en FROM empleado ORDER BY empleado_id";

        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Empleado e = new Empleado();
                e.setEmpleadoId(rs.getInt("empleado_id"));
                e.setNombreUsuario(rs.getString("nombre_usuario"));
                e.setNombre(rs.getString("nombre"));
                e.setApPaterno(rs.getString("ap_paterno"));
                e.setApMaterno(rs.getString("ap_materno"));
                e.setRolId((Integer) rs.getObject("rol_id"));
                e.setBloqueado((Short) rs.getObject("bloqueado"));
                e.setIntentosFallidos((Integer) rs.getObject("intentos_fallidos"));
                e.setUltimoIntento(rs.getTimestamp("ultimo_intento"));
                e.setCreadoEn(rs.getTimestamp("creado_en"));
                lista.add(e);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public boolean insertar(Empleado emp) {
        String sql = "INSERT INTO empleado (nombre_usuario, clave_hash, nombre, ap_paterno, ap_materno, rol_id, bloqueado, intentos_fallidos, creado_en) VALUES (?, ?, ?, ?, ?, ?, 0, 0, NOW())";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, emp.getNombreUsuario());
            ps.setString(2, emp.getClaveHash());
            ps.setString(3, emp.getNombre());
            ps.setString(4, emp.getApPaterno());
            ps.setString(5, emp.getApMaterno());
            ps.setObject(6, emp.getRolId(), Types.INTEGER);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public Empleado buscarPorUsuario(String usuario) {
        String sql = "SELECT * FROM empleado WHERE nombre_usuario = ?";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, usuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Empleado e = new Empleado();
                    e.setEmpleadoId(rs.getInt("empleado_id"));
                    e.setNombreUsuario(rs.getString("nombre_usuario"));
                    e.setClaveHash(rs.getString("clave_hash"));
                    e.setNombre(rs.getString("nombre"));
                    e.setRolId((Integer) rs.getObject("rol_id"));
                    e.setBloqueado((Short) rs.getObject("bloqueado"));
                    e.setIntentosFallidos((Integer) rs.getObject("intentos_fallidos"));
                    return e;
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }
}