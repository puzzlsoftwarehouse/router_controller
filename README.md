Usamos como base uma biblioteca chamada Fluro, apenas adaptamos algumas coisas para funcionar da melhor forma possível.

O Fluro é uma poderosa biblioteca de roteamento para o Flutter que facilita a navegação entre diferentes telas da sua aplicação. Ele oferece uma maneira simples e declarativa de definir e gerenciar as rotas da sua aplicação Flutter. Nesta documentação, vou explicar como você pode usar o Fluro no Flutter para configurar o roteamento em sua aplicação.

**Passo 1: Adicionar Dependência Fluro**

Primeiro, você precisa adicionar a dependência do Fluro ao seu arquivo `pubspec.yaml`. Abra o arquivo `pubspec.yaml` e adicione o seguinte código na seção `dependencies`:

```yaml
dependencies:
  router_controller:
  git:
    url: https://github.com/puzzlsoftwarehouse/router_controller.git
    ref: develop
```

Em seguida, execute `flutter pub get` para baixar a dependência.

**Passo 2: Configurar Rotas**

Agora, você precisa configurar as rotas da sua aplicação. Crie um arquivo onde você irá configurar todas as rotas. Por exemplo, você pode criar um arquivo chamado `routes.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

class Routes {
  static FluroRouter router = FluroRouter();

  static void configureRoutes() {
    // Define a rota inicial
    router.define(
      '/',
      handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
          return YourHomePage();
        },
      ),
    );

    // Defina outras rotas aqui
    router.define(
      '/details/:id',
      handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
          // Recupere o parâmetro 'id' da URL
          final String id = params['id']?.first;
          return DetailsPage(id: id);
        },
      ),
    );
  }
}
```

Certifique-se de importar `fluro` e `flutter/material.dart` no seu arquivo.

**Passo 3: Inicializar o Roteador Fluro**

Para inicializar o roteador Fluro, você deve chamar o método `configureRoutes` que você definiu no passo anterior. Você pode fazer isso na função `main` do seu aplicativo ou em qualquer lugar apropriado:

```dart
void main() {
  // Inicialize o roteador Fluro
  Routes.configureRoutes();

  runApp(MyApp());
}
```

**Passo 4: Navegar para Outras Telas**

Agora que você configurou suas rotas, pode navegar entre as telas usando o roteador Fluro. Por exemplo, para navegar para a tela de detalhes com um ID específico, você pode fazer o seguinte:

```dart
void _navigateToDetailsPage(BuildContext context, String id) {
  String route = '/details/$id';
  Routes.router.navigateTo(context, route, transition: TransitionType.fadeIn);
}
```

Lembre-se de importar o arquivo `routes.dart` onde você configurou as rotas.

**Passo 5: Lidar com Parâmetros de Rota**

Para acessar parâmetros passados na URL da rota, você pode usar `params` no manipulador da rota. Por exemplo, na rota '/details/:id', o parâmetro 'id' pode ser acessado através de `params['id']`.

Isso é uma visão geral básica de como usar o Fluro para o roteamento no Flutter. Você pode personalizar e expandir essas configurações de acordo com as necessidades da sua aplicação. Certifique-se de consultar a documentação oficial do Fluro para obter mais informações e opções avançadas: [https://pub.dev/packages/fluro](https://pub.dev/packages/fluro).
