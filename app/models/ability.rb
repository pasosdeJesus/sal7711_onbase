# encoding: UTF-8

include Devise::Controllers::SignInOut

class Ability  < Sal7711Gen::Ability

  ROLADMIN      = 1
  ROLADMINORG   = 2
  ROLINDEXADOR  = 3
  ROLINV        = 4
  ROLINVANON    = 5

  ROLES = [
    ["Administrador", ROLADMIN],  # 1
    ["Administrador Organización", ROLADMINORG], # 2
    ["Indexador", ROLINDEXADOR], # 3
    ["Investigador", ROLINV], # 4
    ["Investigador Anónimo", ROLINVANON], # 5
    ["", 0] #5
  ]


  BASICAS_PROPIAS =  [
    ['', 'organizacion']
  ]
  @@tablasbasicas = Sip::Ability::BASICAS_PROPIAS + 
    Sal7711Gen::Ability::BASICAS_PROPIAS + 
    BASICAS_PROPIAS  - [
      ['Sip', 'clase'],
      ['Sip', 'etiqueta'],
      ['Sip', 'oficina'],
      ['Sip', 'tclase'],
      ['Sip', 'tdocumento'],
      ['Sip', 'trelacion'],
      ['Sip', 'tsitio']
    ] 
#  def self.tablasbasicas
    # soluciona bug que ocurre solo con unicorn
#    if @@tablasbasicas.length < 13 
#      @@tablasbasicas += [['', 'organizacion']]
#    end
#    return @@tablasbasicas
#  end 


  @@basicas_id_noauto = Sip::Ability::BASICAS_ID_NOAUTO +
    Sal7711Gen::Ability::BASICAS_ID_NOAUTO 

  @@nobasicas_indice_seq_con_id = Sip::Ability::NOBASICAS_INDSEQID +
    Sal7711Gen::Ability::NOBASICAS_INDSEQID 

  @@tablasbasicas_prio = Sip::Ability::BASICAS_PRIO +
    Sal7711Gen::Ability::BASICAS_PRIO 

  @@ultimo_error_aut = "";

  def self.ultimo_error_aut
    @@ultimo_error_aut
  end

  def self.ultimo_error_aut=(v)
    @@ultimo_error_aut = v
  end

  # Se definen habilidades con cancancan
  def initialize(usuario)
    # El primer argumento para can es la acción a la que se da permiso, 
    # el segundo es el recurso sobre el que puede realizar la acción, 
    # el tercero opcional es un diccionario de condiciones para filtrar 
    # más (e.g :publicado => true).
    #
    # El primer argumento puede ser :manage para indicar toda acción, 
    # o grupos de acciones como :read (incluye :show e :index), 
    # :create, :update y :destroy.
    #
    # Si como segundo argumento usa :all se aplica a todo recurso, 
    # o puede ser una clase.
    # 
    # Detalles en el wiki de cancan: 
    #   https://github.com/ryanb/cancan/wiki/Defining-Abilities
    if !usuario
        return
    end
    return if usuario.fechadeshabilitacion
    can :contar, Sip::Ubicacion
    can :buscar, Sip::Ubicacion
    can :lista, Sip::Ubicacion
    can :descarga_anexo, Sip::Anexo
    can :nuevo, Sip::Ubicacion
    if usuario.rol then
      diasv = usuario.diasvigencia
      fechar = usuario.fecharenovacion
      pdom = usuario.email.split("@")
      if pdom.count == 2 
        dom = pdom[1]
        org = ::Organizacion.where(dominiocorreo: dom).take
        if org # plan corporativo correo
          diasv = org.diasvigencia
          fechar = org.fecharenovacion
        end
      end

      can :read, Sal7711Gen::Articulo
      case usuario.rol 
      when Ability::ROLINV, Ability::ROLINVANON
        if !diasv  || !fechar
          @@ultimo_error_aut = 
            "Usuario sin fecha de renovación o tiempo de vigencia"
          return
        end
        fechaf = fechar + diasv
        hoy = Date.today
        if hoy < fechar || hoy > fechaf
          @@ultimo_error_aut = "Sin vigencia"
          return
        end
        can :read, Sal7711Gen::Categoriaprensa
        can :read, Sip::Ubicacion
        can :new, Sip::Ubicacion
        can [:update, :create, :destroy], Sip::Ubicacion
        #can :read, Sip::Actividad
        #can :new, Sip::Actividad
        #can [:update, :create, :destroy], Sip::Actividad
      when Ability::ROLADMINORG
        if !diasv  || !fechar
          @@ultimo_error_aut = 
            "Usuario sin fecha de renovación o tiempo de vigencia"
          return
        end
        fechaf = fechar + diasv
        hoy = Date.today
        if hoy < fechar || hoy > fechaf
          @@ultimo_error_aut = "Sin vigencia"
          return
        end
        can :read, Sal7711Gen::Categoriaprensa
        can :read, Sip::Ubicacion
        can :new, Sip::Ubicacion
        can [:update, :create, :destroy], Sip::Ubicacion
      when Ability::ROLINDEXADOR
        can :manage, Sip::Ubicacion
      when Ability::ROLADMIN
        can :read, Sal7711Gen::Categoriaprensa
        can :manage, Sip::Ubicacion
        #can :manage, Sip::Actividad
        can :manage, Usuario
        can :manage, :tablasbasicas
        @@tablasbasicas.each do |t|
          c = Ability.tb_clase(t)
          can :manage, c
        end
      end
    end
  end

end

