
# Backend Express + MongoDB com JWT

Este é um backend simples com autenticação de usuários usando Node.js, Express, MongoDB e JWT, pronto para ser hospedado na Vercel como funções serverless.

---

## 🚀 Tecnologias

- Node.js  
- Express  
- MongoDB + Mongoose  
- JWT (`jsonwebtoken`)  
- Bcrypt  
- Vercel (Serverless Functions)

---

## 📁 Estrutura

├── api/\
│ │ ├── controllers/\
│	│ ├── authController.js\
│	│ ├── profileController.js\
│	│	└── protectedController.js\
│	├── database/\
│	│	  └──	db.js\
│	├──	middlewares/\
│	│	└──	authMiddleware.js\
│	├── models/\
│	│	└──	user.js\
│	├── routes/\
│	│	├──	auth.js\
│	│	├──	profile.js\
│	│	└──	protected.js\
│	├── services/\
│	│	└──authService.js\
│	└── index.js\
├── node_modules/\
├──	package.json\
└── README.md

---

## 🎥 Vídeo de Demonstração

[Vídeo de Requests para a atividade 1.0.0 e 2.1.0](https://drive.google.com/file/d/1yoE1akUzQKGsK5w5j8S1pdwllzIQHXGq/view?usp=sharing)
