/**
 * Admin module manage user creation.
 * @module admin
 * TODO(...): merge on-save.
 */

error = on if window.'plaft'.\e == -1
document.body.innerHTML = "
  <div class='#{gz.Css \container}'>
    <div class='#{gz.Css \row}'>
		  <div class='#{gz.Css \col-md-4}
		            \ #{gz.Css \col-md-offset-4}'>
      		<div class='#{gz.Css \panel}
      		          \ #{gz.Css \panel-default}'>
			    	<div class='#{gz.Css \panel-heading}'>
			      	<h3 class='#{gz.Css \panel-title}'>Ingreso al Sistema</h3>
			   	  </div>
            #{if error
              then "<div class='#{gz.Css \alert}
          	          \ #{gz.Css \alert-danger}  #{gz.Css \error}'>
                      <a class='#{gz.Css \close}' data-dismiss='alert'>×</a>
                        Usuario y contraseña incorrecta
                   </div>"
              else ''}
			    	<div class='#{gz.Css \panel-body}'>
			      	<form accept-charset='UTF-8' role='form' method='post'>
			      	  	<div class='#{gz.Css \form-group}
			      	  	         \ #{if error
                                then " #{gz.Css \has-error} #{gz.Css \has-feedback}"
                                else ''}'>
			      		    <input class='#{gz.Css \form-control}'
			      		           placeholder='Usuario'
			      		           name='username'
			      		           type='text'>
			      		  </div>
			        		<div class='#{gz.Css \form-group}
                            \ #{if error
                              then " #{gz.Css \has-error} #{gz.Css \has-feedback}"
                              else ''}'>
			        			<input class='#{gz.Css \form-control}'
			        			       placeholder='Password'
			        			       name='password'
			        			       type='password'>
			        		</div>
			        		<input class='#{gz.Css \btn}
			        		            \ #{gz.Css \btn-lg}
			        		            \ #{gz.Css \btn-primary}
			        		            \ #{gz.Css \btn-block}' type='submit'
			        		       value='Ingresar'>
			        </form>
			      </div>
			  </div>
		  </div>
	  </div>
  </div>"


/* vim: ts=2 sw=2 sts=2 et: */
