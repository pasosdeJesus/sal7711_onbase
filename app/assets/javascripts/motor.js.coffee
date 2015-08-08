

@sal7711_onbase_prepara_eventos_comunes = (root) ->

  $(document).on('focusin', '#buscar_mundep', (e) ->
    return busca_gen($(this), null, puntomontaje + "/mundep.json");
  )

  $('#organizacion_autoregistro').change( (e) ->
    if (this.checked) 
      alert('dechequea')
    else
      alert('chequea')
  
    return       
  )

