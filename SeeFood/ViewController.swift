//
//  ViewController.swift
//  SeeFood
//
//  Created by Felipe Vallejo on 5/9/21.
//

/* En el archivo Info.plist modificaremos la privacidad
de la app para pedir permiso al usuario de utilizar la cámara del dispositivo */

import UIKit
// Para tener la funcionalidad de Coreml debemos importarlo
import CoreML
/* Para tener acceso a la cámara del
celular debemos importar la librería de Vision*/
import Vision

/* Además de heredar a UIViewController,
necesitamos heredar a UIImagePickerControllerDelegate
y UINavigationControllerDelegate para escoger
fotos de la galería y navegar por pestañas, respectivamente.*/
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Creamos un fondo para mostrar las fotos tomadas
    @IBOutlet weak var imageView: UIImageView!
    
    // Creamos un objeto para capturar fotos
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Implementamos la funcionalidad de la aplicación con el objeto previamente creado
        imagePicker.delegate = self
        // Especificamos de donde sacamos la foto, puede ser de la cámara o de galería
        imagePicker.sourceType = .camera
        // Podemos añadir la funcionalidad para editar la foto, en este caso no lo haremos
        imagePicker.allowsEditing = false
    }
    
    /* En la siguiente función enviaremos los
    datos de la imagen tomada al modelo para que la clasifique */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /* Enviaremos la imagen original y haremos casting
        para que se procese como una UIImage */
        if let userPickedImage = info[.originalImage] as? UIImage {
            imageView.image = userPickedImage
            /* Para recibir la predicción de las fotos tomadas necesitamos convertir a la foto a una imagen compatible con las especificaciones de CoreML */
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("No se puede convertir la imagen")
            }
            // Aquí clasificamos la imagen
            detect(image: ciImage)
        }
        // Después de clasificar la imagen descartaremos la pestaña para elegir las fotos
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    /* En esta función haremos análisis de la
    imagen capturada con funcionalidad del modelo Inceptionv3 */
    func detect(image: CIImage){
        // Haremos un instance del modelo Inceptionv3
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Modelo no encontrado")
        }
        // Haremos una solicitud al modelo para utilizar su funcionalidad
        let request = VNCoreMLRequest(model: model) { (request, error) in
            // Guardaremos los resultados que el modelo hizo acerca de la imagen
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("No se pudo procesar la imagen")
            }
            print(results)
            
            // Aquí diremos si la imagen muestra un Hot-dog o no
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog"){
                    // Aquí accedemos al título de la pantalla lo modificamos según la predicción del modelo
                    self.navigationItem.title = "HotDog!!"
                } else {
                    self.navigationItem.title = "Not a HotDog"
                }
            }
        }
        
        // Aquí especificamos la imagen que queremos clasificar
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    // Creamos un botón para tomar las fotos
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        // Cuando presionamos este botón presentaremos la pestaña para escoger fotos
        present(imagePicker, animated: true, completion: nil)
    }
}
