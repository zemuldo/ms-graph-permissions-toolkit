import React from 'react'
import Box from "@mui/material/Box";
import { Link, Typography } from '@mui/material';

const Footer = () => (
  <Box sx={{ bgcolor: "background.paper", p: 6 }} component="footer">
    <Typography variant="h6" align="center" gutterBottom>
      Build for love of Microsoft Hack
    </Typography>
    <Typography
      variant="subtitle1"
      align="center"
      color="text.secondary"
      component="p"
    >
      This tool helps you explore the Graph API permissions
    </Typography>
    <Typography variant="body2" color="text.secondary" align="center">
      {"Copyright © "}
      <Link color="inherit" href="https://hackbox.microsoft.com/project/1046">
        HackBox
      </Link>{" "}
      {new Date().getFullYear()}
      {"."}
    </Typography>
  </Box>
);

export default Footer;