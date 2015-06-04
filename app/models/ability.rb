# encoding: UTF-8
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

    @@tablasbasicas = @@tablasbasicas + [
      ['', 'organizacion']
    ]
   def self.tablasbasicas
     # soluciona bug que ocurre solo con unicorn
     if @@tablasbasicas.length < 13 
       @@tablasbasicas += [['', 'organizacion']]
     end
     return @@tablasbasicas
   end 



    @@basicas_seq_con_id = @@basicas_seq_con_id + [
      ['', 'organizacion']
    ]
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
      if !usuario || usuario.fechadeshabilitacion
        return
      end
      can :contar, Sip::Ubicacion
      can :buscar, Sip::Ubicacion
      can :lista, Sip::Ubicacion
      can :descarga_anexo, Sip::Anexo
      can :nuevo, Sip::Ubicacion
      #can :nuevo, Sip::Victima
      if usuario && usuario.rol then
        can :read, Sal7711Gen::Categoriaprensa
        case usuario.rol 
        when Ability::ROLINV
          can :read, Sip::Ubicacion
          can :new, Sip::Ubicacion
          can [:update, :create, :destroy], Sip::Ubicacion
          #can :read, Sip::Actividad
          #can :new, Sip::Actividad
          #can [:update, :create, :destroy], Sip::Actividad
        when Ability::ROLADMIN
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

