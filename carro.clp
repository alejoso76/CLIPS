;;****************
;;* DEFFUNCTIONS *
;;****************

(deffunction ask-question (?question $?allowed-values)
   (printout t ?question)
   (bind ?answer (read))
   (if (lexemep ?answer) 
       then (bind ?answer (lowcase ?answer)))
   (while (not (member ?answer ?allowed-values)) do
      (printout t ?question)
      (bind ?answer (read))
      (if (lexemep ?answer) 
          then (bind ?answer (lowcase ?answer))))
   ?answer)

(deffunction yes-or-no-p (?question)
   (bind ?response (ask-question ?question yes no y n))
   (if (or (eq ?response yes) (eq ?response y))
       then yes 
       else no))

;;;***************
;;;* REGLAS DE CONSULTA *
;;;***************

(defrule determine-engine-state ""
   (not (engine-starts ?))
   (not (repair ?))
   =>
   (assert (engine-starts (yes-or-no-p "El motor enciende? (yes/no)? "))))
   
(defrule determine-runs-normally ""
   (engine-starts yes)
   (not (repair ?))
   =>
   (assert (runs-normally (yes-or-no-p "El motor funciona correctamente? (yes/no)? "))))

(defrule determine-rotation-state ""
   (engine-starts no)
   (not (repair ?))   
   =>
   (assert (engine-rotates (yes-or-no-p "El motor rota? (yes/no)? "))))
   
(defrule determine-sluggishness ""
   (runs-normally no)
   (not (repair ?))
   =>
   (assert (engine-sluggish (yes-or-no-p "El motor está lento? (yes/no)? "))))
   
(defrule determine-misfiring ""
   (runs-normally no)
   (not (repair ?))
   =>
   (assert (engine-misfires (yes-or-no-p "El motor falla? (yes/no)? "))))

(defrule determine-knocking ""
   (runs-normally no)
   (not (repair ?))
   =>
   (assert (engine-knocks (yes-or-no-p "El motor golpea? (yes/no)? "))))

(defrule determine-low-output ""
   (runs-normally no)
   (not (repair ?))
   =>
   (assert (engine-output-low
               (yes-or-no-p "Es lenta la salida del motor? (yes/no)? "))))

(defrule determine-gas-level ""
   (engine-starts no)
   (engine-rotates yes)
   (not (repair ?))
   =>
   (assert (tank-has-gas
              (yes-or-no-p "El tanque tiene gasolina? (yes/no)? "))))

(defrule determine-battery-state ""
   (engine-rotates no)
   (not (repair ?))
   =>
   (assert (battery-has-charge
              (yes-or-no-p "La bateria esta cargada? (yes/no)? "))))

(defrule determine-point-surface-state ""
   (or (and (engine-starts no)      
            (engine-rotates yes))
       (engine-output-low yes))
   (not (repair ?))
   =>
   (assert (point-surface-state
      (ask-question "Cual es el estado de la superficie de los puntos (normal / quemado / contaminado)? "
                    normal quemado contaminado))))

(defrule determine-conductivity-test ""
   (engine-starts no)      
   (engine-rotates no)
   (battery-has-charge yes)
   (not (repair ?))
   =>
   (assert (conductivity-test-positive
              (yes-or-no-p "La prueba de conductividad para la bobina de encendido es positiva (yes / no)? "))))

;;;****************
;;;* REGLAS DE REPARACIÓN *
;;;****************

(defrule normal-engine-state-conclusions ""
   (runs-normally yes)
   (not (repair ?))
   =>
   (assert (repair "Reparacion innecesaria.")))

(defrule engine-sluggish ""
   (engine-sluggish yes)
   (not (repair ?))
   =>
   (assert (repair "Limpie la linea de combustible. "))) 

(defrule engine-misfires ""
   (engine-misfires yes)
   (not (repair ?))
   =>
   (assert (repair "Ajuste de separacion de puntos.")))     

(defrule engine-knocks ""
   (engine-knocks yes)
   (not (repair ?))
   =>
   (assert (repair "Ajuste de tiempos (Arbol de levas).")))

(defrule tank-out-of-gas ""
   (tank-has-gas no)
   (not (repair ?))
   =>
   (assert (repair "Añadir gasolina.")))

(defrule battery-dead ""
   (battery-has-charge no)
   (not (repair ?))
   =>
   (assert (repair "Cargar la bateria")))

(defrule point-surface-state-burned ""
   (point-surface-state burned)
   (not (repair ?))
   =>
   (assert (repair "Reemplace los puntos.")))

(defrule point-surface-state-contaminated ""
   (point-surface-state contaminated)
   (not (repair ?))
   =>
   (assert (repair "Limpie los puntos.")))

(defrule conductivity-test-positive-yes ""
   (conductivity-test-positive yes)
   (not (repair ?))
   =>
   (assert (repair "Repare el cable conductor del distribuidor.")))

(defrule conductivity-test-positive-no ""
   (conductivity-test-positive no)
   (not (repair ?))
   =>
   (assert (repair "Reemplace la bobina de encendido.")))

(defrule no-repairs ""
  (declare (salience -10))
  (not (repair ?))
  =>
  (assert (repair "Llevar el automovil a un mecánico.")))

;;;********************************
;;;* REGLAS DE INICIO Y CONCLUSIÓN *
;;;********************************

(defrule system-banner ""
  (declare (salience 10))
  =>
  (printout t crlf crlf)
  (printout t "Sistema experto de diagnostico mecanico")
  (printout t crlf crlf))

(defrule print-repair ""
  (declare (salience 10))
  (repair ?item)
  =>
  (printout t crlf crlf)
  (printout t "Reparacion sugerida: ")
  (printout t crlf crlf)
  (format t " %s%n%n%n" ?item))

