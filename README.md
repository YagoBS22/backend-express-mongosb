
# Backend Express + MongoDB com JWT e Frontend Simples

Este projeto consiste em um backend robusto construído com Node.js e Express, utilizando MongoDB (com Mongoose) para persistência de dados e autenticação baseada em JSON Web Tokens (JWT). Além das funcionalidades de API, o projeto também serve uma interface de frontend simples (HTML, CSS, JavaScript) para interação com o backend.

---

## 🚀 Tecnologias Utilizadas

-   **Backend:**
    -   Node.js
    -   Express.js
    -   MongoDB (com Mongoose como ODM)
    -   JSON Web Tokens (`jsonwebtoken`) para autenticação
    -   `bcrypt.js` para hashing de senhas
    -   `dotenv` para gerenciamento de variáveis de ambiente
    -   `cors` para habilitar Cross-Origin Resource Sharing
    -   `validator` para validação de dados de entrada
-   **Frontend:**
    -   HTML5
    -   CSS3
    -   JavaScript (Vanilla)
-   **Deploy:**
    -   Vercel (Serverless Functions)

---

## ✨ Funcionalidades Principais

-   **Autenticação de Usuários:**
    -   Registro de novos usuários com hashing de senha.
    -   Login de usuários existentes e geração de token JWT.
    -   Middleware de autenticação para proteger rotas.
-   **Gerenciamento de Perfil:**
    -   Rota protegida para buscar informações do perfil do usuário autenticado.
-   **Gerenciamento de Tarefas (To-Do List):**
    -   CRUD completo para itens de tarefas (Criar, Ler, Atualizar, Deletar).
    -   Tarefas são associadas ao usuário autenticado.
-   **Rota Protegida Genérica:**
    -   Exemplo de uma rota que requer autenticação para acesso.
-   **Servir Frontend Estático:**
    -   Interface de frontend simples (HTML, CSS, JS) servida pela mesma aplicação Express, permitindo interação direta com a API.

---

## 📁 Estrutura do Projeto

├── api/\
│   ├── controllers/\
│   │   ├── authController.js\
│   │   ├── profileController.js\
│   │   ├── protectedController.js\
│   │   └── todoController.js\
│   ├── database/\
│   │   └── db.js\
│   ├── middlewares/\
│   │   └── authMiddleware.js\
│   ├── models/\
│   │   ├── todo.js\
│   │   └── user.js\
│   ├── public/\
│   │   ├── css/\
│   │   │   └── style.css\
│   │   ├── js/\
│   │   │   ├── auth.js\
│   │   │   ├── loginPage.js\
│   │   │   ├── protectedApi.js\
│   │   │   ├── registerPage.js\
│   │   │   ├── todosPage.js\
│   │   │   └── ui.js\
│   │   ├── index.html\
│   │   ├── login.html\
│   │   ├── protected.html\
│   │   ├── register.html\
│   │   └── todos.html\
│   ├── routes/\
│   │   ├── auth.js\
│   │   ├── profile.js\
│   │   ├── protected.js\
│   │   └── todo.js\
│   ├── services/\
│   │   ├── authService.js\
│   │   └── todoService.js\
│   └── index.js\(servidor Express)
├── node_modules/\
├── requests/\
├── package-lock.json\
├── package.json\
├── README.md\
└── vercel.json

---

## 🎥 Vídeo de Demonstração
Atividade Avaliativa IV.v2.1.0: https://drive.google.com/file/d/1yoE1akUzQKGsK5w5j8S1pdwllzIQHXGq/view?usp=sharing
Atividade Avaliativa IV.Final: https://drive.google.com/file/d/1WQNqAZWeLFKW7L8DY6p25XzP8u7SP2Xl/view?usp=drive_link
