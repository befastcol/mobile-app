import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Text(
                'TECNOLOGIA Y SOLUCIONES DE INFRAESTRUCTURA, autorizo la creación de la aplicación (BE FAST), es una sociedad legalmente constituida conforme a las Leyes de México; teniendo sus oficinas en el domicilio ubicado en el número 1095 INTERIOR 1 del Boulevard Camino Real de la Colonia Puerto Paraíso, en la Ciudad de Colima, Colima, código postal 28018.',
              ),
              SizedBox(height: 16),
              Text(
                '“BE FAST” es un desarrollo de una plataforma de entrega de alimentos y diversos artículos a través de la cual “BE FAST” presta los Servicios a los Restaurantes o empresas y negocios Afiliados en zonas cercanas y geográficas específicas, en que los Usuarios pueden realizar Pedidos directos en dichos Restaurantes o empresas y negocios Afiliados, para que los Socios Repartidores recojan y entreguen a los Usuarios de (“BE FAST”).',
              ),
              SizedBox(height: 16),
              Text(
                'Al descargar o usar la aplicación, estos términos se aplicarán automáticamente a usted; por lo tanto, debe asegurarse de leerlos detenidamente antes de usar la aplicación. No está permitido copiar ni modificar la aplicación, ninguna parte de la aplicación ni nuestra marca comercial de ninguna manera. No se permite intentar extraer el código fuente de la aplicación, y tampoco debe intentar traducir la aplicación a otros idiomas o hacer versiones derivadas.',
              ),
              SizedBox(height: 16),
              Text(
                '(BE FAST) se compromete a garantizar que la aplicación sea lo más útil y eficiente posible. Por esa razón, nos reservamos el derecho de realizar cambios de en la aplicación. Nunca le cobraremos por la aplicación o sus servicios sin dejarle muy claro exactamente por lo que está pagando.',
              ),
              SizedBox(height: 16),
              Text(
                'La aplicación (BE FAST) almacena y procesa los datos personales que nos ha proporcionado para proporcionar nuestro Servicio. Es su Responsabilidad mantener su teléfono y acceso seguros a la aplicación. Por lo tanto, le recomendamos que no haga jailbreak o rootee su teléfono, que es el proceso de eliminar las restricciones y limitaciones de software impuestas por el sistema operativo oficial de su dispositivo. Podría hacer que su teléfono sea vulnerable a malware/virus/programas maliciosos, comprometer las características de seguridad de su teléfono y podría significar que la aplicación (BE FAST) no funcionara correctamente o no funcionara en absoluto.',
              ),
              SizedBox(height: 16),
              Text(
                'Debe tener en cuenta que hay ciertas cosas de las que (BE FAST) no se responsabiliza. Ciertas funciones de la aplicación requerirán que la aplicación tenga una conexión puede ser Wi-Fi o le puede proporcionar su proveedor de red móvil, pero (BE FAST) no puede asumir la responsabilidad que la aplicación no funcione con plena funcionalidad si no tiene acceso a Wi-Fi o no tiene datos móviles.',
              ),
              SizedBox(height: 16),
              Text(
                'Con respecto a la responsabilidad de (BE FAST). Por su uso de la aplicación, cuando la utiliza, es importante tener en cuenta que, aunque nos esforzamos para garantizar que este actualizada y sea correcta en todo momento, confiamos en terceros para proporcionarnos información para que podamos ponerla a su disposición. (BE FAST), no acepta ninguna responsabilidad por cualquier perdida directa o indirecta que usted experimenta como resultado de confiar totalmente en esta funcionalidad de la aplicación.',
              ),
              SizedBox(height: 16),
              Text(
                'En algún momento es posible que deseemos actualizar la aplicación. La aplicación está actualmente disponible en Android y IOS: los requisitos para el sistema y para cualquier sistema adicional al que decidamos extender la disponibilidad de la aplicación, pueden cambiar y deberán descargar las actualizaciones si desea seguir utilizando la aplicación. (BE FAST) no promete que siempre actualizara la aplicación para que sea relevante para usted y/o funcione con la versión Android que haya instalado en su dispositivo.',
              ),
              SizedBox(height: 16),
              Text(
                "CAMBIOS A ESTOS TERMINOS Y CONDICIONES",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Podemos actualizar nuestra Política de privacidad de vez en cuando. Por lo tanto, se recomienda revisar esta página periódicamente para cualquier cambio. Le notificaremos cualquier cambio publicado la nueva política de privacidad en esta página. Estos cambios son efectivos para mejorar la página.',
              ),
              SizedBox(height: 16),
              Text(
                "CONTACTOS",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Si tiene alguna duda o sugerencia sobre nuestros Términos y Condiciones, no dude en ponerse en contacto con nosotros en (BE FAST).',
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
