

@sal7711_onbase_prepara_eventos_comunes = (root) ->
  $('#organizacion_autoregistro').change( (e) ->
    if (this.checked) 
      alert('dechequea')
    else
      alert('chequea')
  
    return       
  )

