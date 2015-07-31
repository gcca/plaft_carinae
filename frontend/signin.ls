#                    __
#               _--'"  "`--_
#        /( _--'_.        =":-_
#       | \___/{          '>_ ".
#       |-"  ' /\            :  \:
#      /       { `-_*         \  |
#     '/        -:='           |  \:
#     {   '  -___\            |/   |
#    |   :   / (.             |     /
#    `.   .  | | \_-'-.     )\|    '
#     |    :  ` \ __-'-    /      |
#      \    ".   "'--__-''"       /
#       \     "--"''   ,.'":     /
#        `-_        ''" .."   _-'
#           "'--__      __--'"    cristHian Gz. (gcca)
#                 ""--""
error = on if window.'plaft'.\e == -1
document.body.innerHTML = "
<div class='#{gz.Css \navbar}
          \ #{gz.Css \navbar-inverse}
          \ #{gz.Css \navbar-fixed-top}' role='navigation'>

  <div class='#{gz.Css \container}'>

    <div class='#{gz.Css \navbar-header}'>
      <button type='button' class='#{gz.Css \navbar-toggle}'
          data-toggle='collapse' data-target='.#{gz.Css \navbar-collapse}'>
        <span class='#{gz.Css \sr-only}'>Toggle navigation</span>
        <span class='#{gz.Css \icon-bar}'></span>
        <span class='#{gz.Css \icon-bar}'></span>
        <span class='#{gz.Css \icon-bar}'></span>
      </button>
      <a class='#{gz.Css \navbar-brand}' href='#'>
        PLAFT<small>sw</small>
      </a>
    </div>

    <div class='#{gz.Css \navbar-collapse}
              \ #{gz.Css \collapse}'>

      <form class='#{gz.Css \navbar-form}
                 \ #{gz.Css \navbar-right}' role='form' method='post'>

        <div class='#{gz.Css \form-group}
                    #{if error
                    then " #{gz.Css \has-error} #{gz.Css \has-feedback}"
                    else ''}'>

          <input type='text' placeholder='Usuario' name='username'
              style='width:17em'
              class='#{gz.Css \form-control}'>


          #{if error
            then "<span class='#{gz.Css \glyphicon}
                             \ #{gz.Css \glyphicon-remove}
                             \ #{gz.Css \form-control-feedback}'></span>"
            else ''}

        </div>


        <div class='#{gz.Css \form-group}
                    #{if error
                    then " #{gz.Css \has-error} #{gz.Css \has-feedback}"
                    else ''}'>

          <input type='password' placeholder='Contraseña' name='password'
              style='width:11em'
              class='#{gz.Css \form-control}'>

          #{if error
            then "<span class='#{gz.Css \glyphicon}
                             \ #{gz.Css \glyphicon-remove}
                             \ #{gz.Css \form-control-feedback}'></span>"
            else ''}

        </div>

        <button type='submit' class='#{gz.Css \btn} #{gz.Css \btn-success}'>
          Ingresar
        </button>

      </form>

    </div>

  </div>

</div>

<div class='#{gz.Css \jumbotron}' style='padding-bottom: 11px'>

  <div class='#{gz.Css \container}'>
    #{
      if (location.'href'.'indexOf' 'restricted-access') isnt -1
      then '<span style=\'color:red\'>
              Es necesario estar autenticado para usar la aplicación.
            </span>'
      else ''
    }
    <span class='#{gz.Css \col-md-2}' style='padding:0px'>
      <img src='/static/img/prevencion.png' style='float: left;margin: 0 40 0 10;'>
    </span>
    <span class='#{gz.Css \col-md-8}' style='padding:0px'>
    <h4 style='margin: 0px; text-align:center'>
      SOFTWARE DE PREVENCION DEL LAVADO DE ACTIVOS Y DEL FINANCIAMIENTO DEL <br/>
      TERRORISMO APLICABLE A LOS DESPACHADORES DE ADUANA  -  PLAFT <br/>
    </h4>
    <h2 style='text-align:center;'>PLAFT - UIF</h2>
    </span>
    <span class='#{gz.Css \col-md-2}' style='padding:0px'>
      <img src='/static/img/torre.png' style='float: left;margin: 0 40 0 10;'>
    </span>

    <p class='#{gz.Css \jumbotron-options}
            \ #{gz.Css \pull-right}'>

      <a class='#{gz.Css \visible-xs}'>
        <form class='#{gz.Css \navbar-form}
                   \ #{gz.Css \navbar-right}' role='form' method='post'>

          <div class='#{gz.Css \form-group}
                      #{if error
                      then " #{gz.Css \has-error} #{gz.Css \has-feedback}"
                      else ''}'>

            <input type='text' placeholder='Email' name='username'
                class='#{gz.Css \form-control}'>


            #{if error
              then "<span class='#{gz.Css \glyphicon}
                               \ #{gz.Css \glyphicon-remove}
                               \ #{gz.Css \form-control-feedback}'></span>"
              else ''}

          </div>


          <div class='#{gz.Css \form-group}
                      #{if error
                      then " #{gz.Css \has-error} #{gz.Css \has-feedback}"
                      else ''}'>

            <input type='password' placeholder='Password' name='password'
                class='#{gz.Css \form-control}'>

            #{if error
              then "<span class='#{gz.Css \glyphicon}
                               \ #{gz.Css \glyphicon-remove}
                               \ #{gz.Css \form-control-feedback}'></span>"
              else ''}

          </div>

          <button type='submit' class='#{gz.Css \btn} #{gz.Css \btn-success}'>
            Ingresar
          </button>

        </form>
      </a>
    </p>

  </div>

</div>

  #{if error
      then "<div class='#{gz.Css \col-md-12}' style='text-align:center'>
              <div class='#{gz.Css \col-md-4}'>&nbsp;</div>
              <div class='#{gz.Css \alert} #{gz.Css \alert-danger} #{gz.Css \col-md-5}'>
              Usted no es una persona autorizada para ingresar al sistema <strong>PLAFT - UIF</strong> <br/>
              Comunicarse con <strong>CAVASOFT S.A.C.</strong> - <strong>Teléfono:</strong> 449-6929  <br/>
              <a>ventas@cavasoftsac.com</a>, <a>cesarvargas@cavasoftsac.com</a></div></div>"
    else ''}
  <div class='#{gz.Css \container}'>

    <div class='#{gz.Css \row} #{gz.Css \publicity}'>
      <div class='#{gz.Css \col-md-4}'>
        <h4>¿Qué es el lavado de activos?</h4>
        <p style='text-align:justify;border: 1px solid;padding: 10px;'>
          El lavado de activos es el conjunto de operaciones realizadas
         \ por una o más personas, destinadas a ocultar o disfrazar el
         \ origen ilícito de bienes o recursos que provienen de actividades
         \ delictivas tales como el narcotráfico, el tráfico de armas, el
         \ tráfico de personas, el secuestro, la corrupción, etc. A estos
         \ delitos se les conoce como delitos precedentes.</p>
        </p>
      </div>


      <div class='#{gz.Css \col-md-4}'>
        <div class='#{gz.Css \col-md-12}' style='text-align:center'>
          <img src='/static/img/sbs.png' style='margin: 5 15 5 15;'>
          <img src='/static/img/uif.png' style='margin: 5 15 5 15;'>
        </div>
        <div class='#{gz.Css \col-md-12}'>
          <h4 style='text-align:center'>RESOLUCION SBS N° 2249-2013</h4>
        </div>
        <div class='#{gz.Css \col-md-12}' style='text-align:center'>
          <img src='/static/img/sunat.png' style='margin-right: 7px;'>
          <img src='/static/img/aduana.png' style='margin-left: 7px;'>
        </div>
        <div class='#{gz.Css \col-md-12}'>
          <h4 style='text-align:center'>ORGANISMO SUPERVISOR</h4>
        </div>
      </div>


      <div class='#{gz.Css \col-md-4}'>
        <h4>¿Que Prevención de lavado de activos?</h4>
        <p style='text-align:justify;border: 1px solid;padding: 10px;'>
          Conjunto de información de las operaciones del sujeto obligado,
          \ cuya finalidad es prevenir y evitar que los servicios de comercio
          \ exterior que se ofrecen sean utilizados con fines ilícitos.
          \ Con la identificacion oportuna de operaciones inusuales y/o
          \ sospechosas, utilizando las señales de alerta aplicable a
          \ los Despachadores de Aduana.
          <br> &nbsp;
        </p>
     </div>

    </div>
    <div class='#{gz.Css \col-md-12}' style='text-align:center;margin: 25 0 25 0;'>
      <p>Navegadores recomendados: &nbsp;&nbsp;
      <a title='Mozilla Firefox' href='https://www.mozilla.org/en-US/firefox/new/'
         target='_blank'>
        <img src='/static/img/mozilla.png' style='width:32px' />
      </a>
      &nbsp;&nbsp;&nbsp;&nbsp;
      <a title='Google Chrome'
         href='https://www.google.com/chrome/browser/desktop/index.html'
         target='_blank'>
        <img src='/static/img/chrome.png' style='width:32px' />
      </a>
      &nbsp;&nbsp;&nbsp;&nbsp;
      <a title='Opera' href='http://www.opera.com/es'
         target='_blank'>
        <img src='/static/img/opera.png' style='width:32px' />
      </a>
      &nbsp;&nbsp;&nbsp;&nbsp;
      <a title='Safari' href='https://www.apple.com/safari/'
         target='_blank'>
        <img src='/static/img/safari.png' style='width:32px' />
      </a>

      </p>
    </div>
    <div class='#{gz.Css \col-md-12}'><hr></div>

    <footer>
      <p class='#{gz.Css \pull-left}'>
        <img src='/static/img/CAA.png'/>
        #{'&nbsp;'*3}<strong>CAVASOFT S.A.C. </strong><br/>
        #{'&nbsp;'*27}<strong>Telefono:</strong> 449-6929 / 94977-8478 <br/>
        #{'&nbsp;'*27}<a href='ventas@cavasoftsac.com'>ventas@cavasoftsac.com</a><br/>
        #{'&nbsp;'*27}<a href='cesarvargas@cavasoftsac.com'>cesarvargas@cavasoftsac.com</a>
      </p>
      <p class='#{gz.Css \pull-right}'>
        Marca registrada &copy; <br/>
        Registro Indecopi <strong>123456</strong>
      </p>
      <!-- cristHian Gz. (gcca) - http://gcca.tk -->
      <!-- Cristhian Alberto Gonzales Castillo -->
    </footer>
</div>"
