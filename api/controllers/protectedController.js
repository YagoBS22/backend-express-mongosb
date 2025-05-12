const protectedController = {
    accessProtected: (req, res) => {
      res.send("Access granted to protected route!");
    }
  };
  export default protectedController;