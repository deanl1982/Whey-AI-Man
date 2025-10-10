sudo bash -c 'cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
  <head>
    <title>Whey-AI, Man!</title>
    <style>
      body {
        background-color: #0d1117;
        color: #c9d1d9;
        font-family: Arial, sans-serif;
        text-align: center;
        padding-top: 100px;
      }
      h1 {
        color: #58a6ff;
      }
    </style>
  </head>
  <body>
    <h1>Welcome to Whey-AI, Man!</h1>
    <p>The Nginx service is up and the website it running :)</p>
    <p>Cheers, Dean</p>
  </body>
</html>
EOF'