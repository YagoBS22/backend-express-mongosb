const profileController = {
    getProfile: (req, res) => {
        res.json({ user: req.user });
    }
};

export default profileController;