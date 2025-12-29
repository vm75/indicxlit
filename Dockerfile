FROM python:3.9-slim
RUN pip install ai4bharat-transliteration flask flask-cors
# Create the launcher script
RUN echo 'from ai4bharat.transliteration import xlit_server; app, engine = xlit_server.get_app(); app.run(host="0.0.0.0", port=4321)' > app.py
EXPOSE 4321
CMD ["python", "app.py"]
