---
title: "How to Query Google Street View Static API with Python (UPDATED IN 2020)"
date: 2020-05-31
header:
  image: /assets/images/street-view/google-map-platform.png
  teaser: /assets/images/street-view/google-map-platform.png
  caption: Illustration of Google Map Platform
tags:
- google-streetview
- data-source
- computer-vision
- api
- python-oop
categories:
- Project
---

The [Google Street View Static API](https://developers.google.com/maps/documentation/streetview/intro) is Google's straightforward HTTP-based API for developers to access its massive collection of street view pictures. Although it's a paid service, being able to query the service with large batches enables us to create our own image-based modeling dataset. In this post, I will walk you through how I created a Python class for accesss the street view API.

## Key Facts about the Street View Static API (as of May 2020)

Before we get started on the codes, I am listing some of the key specs about the street view API that's important when querying the service.

* In order to query the API, you will need to register your own Google Cloud Platform account, enable billing for your project, and create a Google API key for the Street View API. Follow [this official guidance](https://developers.google.com/maps/documentation/streetview/get-api-key) to obtain your API key
* The cost of each request for a static Street View panorama is around 0.007 USD - 0.0056 USD at the time this post is published (May, 2020)
    * Google's API policies, including the pricing policy, are known to be changing over time. Be sure to check the pricing before doing your queries.
* The API is a standard HTTP-based API. The parameters of the API can be found [here](https://developers.google.com/maps/documentation/streetview/intro#url_parameters)
* You also have the possibility to request the image metadata from the API without requesting the actual street view picture. **The metadata request is free of charge!** You can access the documentation of the metadata request [here](https://developers.google.com/maps/documentation/streetview/metadata#url_parameters).
    * The metadata includes a field called `status`. If your street view request will return available street view picture, this `status` field will have the value `"OK"`. In other words, using the metadata requests to pre-screen any of your street view request will save you from paying for invalid request where no street view is available.
* There is an open-source Python package [`google_streetview`](https://pypi.org/project/google-streetview/) available for direct Python usage. However, I did not find the option to interact with the Metadata as precreening as described above. If you would rather skip the mechanism around Metadata, using this package will be an easier option than writing your own codes for the API.

## Experiment with Single API Request

In this section, I will be testing the Street View API with a valid address, just to showcase the expected results from requests. Throughout this notebook, I will be using the powerful Python package [`requests`](https://requests.readthedocs.io/en/master/) to fulfill the requests I send to the API service.


```python
# using Python
import requests
```


```python
meta_base = 'https://maps.googleapis.com/maps/api/streetview/metadata?'
pic_base = 'https://maps.googleapis.com/maps/api/streetview?'
api_key = 'your_api_key'
# using my graduate school almar mater, GWU, as an example
location = '2121 I St NW, Washington, DC 20052'
```

The `requests` package allows for http request parameter input with the format of Python `dict`. I'm creating the parameters below in this format:


```python
# define the params for the metadata reques
meta_params = {'key': api_key,
               'location': location}
# define the params for the picture request
pic_params = {'key': api_key,
              'location': location,
              'size': "640x640"}
```


```python
# obtain the metadata of the request (this is free)
meta_response = requests.get(meta_base, params=meta_params)
```

The response of this request is in JSON format. `requests` package allow for direct access to the content in JSON format with the `.json()` method.


```python
# display the contents of the response
# the returned value are in JSON format
meta_response.json()
```




    {'copyright': '© Google',
     'date': '2018-10',
     'location': {'lat': 38.90070052863041, 'lng': -77.04765170627219},
     'pano_id': 'D9eMOXkf78VujC2w_0AmCA',
     'status': 'OK'}

The metadata here indicates the `status` is `"OK"`. Therefore, the request will be able to return valid information.


```python
pic_response = requests.get(pic_base, params=pic_params)
```

The `Response` object returned with a `get` function has the HTTP headers information. It is worthwhile to examine the contents.


```python
for key, value in pic_response.headers.items():
    print(f"{key}: {value}")
```

    Content-Type: image/jpeg
    [truncated for demonstration purpose]
    Content-Length: 75839
    X-XSS-Protection: 0
    X-Frame-Options: SAMEORIGIN
    Cache-Control: public, max-age=86400
    Age: 1300
    [truncated for demonstration purpose]


The `Response` object also has an `ok` attribute, which indicates if the request receives correct responses from the server.


```python
pic_response.ok
```




    True



Writing the picture to local disk and display it here:


```python
with open('test.jpg', 'wb') as file:
    file.write(pic_response.content)
# remember to close the response connection to the API
pic_response.close()
```


```python
# using matpltolib to display the image
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
plt.figure(figsize=(10, 10))
img=mpimg.imread('test.jpg')
imgplot = plt.imshow(img)
plt.show()
```


![png](/assets/images/street-view/output_19_0.png)


## Writing a Python Class for the API requests

Now that I'm familiar with the data structure and the mechanism of the API calls, I've written a class `StreetViewer` for a single street view request. I have added in-line comments to help with understanding the inner-work of this class. Feel free to create your own from scratch or using mine as the basis.

**Note**: This class is created for my own purpose to query the API effeciently and has not been tested for general usage. Therefore, these codes are for demonstration purpose only.


```python
# requests and json are the dependencies
import requests
import json
import matplotlib.pyplot as plt
import matplotlib.image as mpimg


class StreetViewer(object):
    def __init__(self, api_key, location, size="640x640",
                 folder_directory='./streetviews/', verbose=True):
        """
        This class handles a single API request to the Google Static Street View API
        api_key: obtain it from your Google Cloud Platform console
        location: the address string or a (lat, lng) tuple
        size: returned picture size. maximum is 640*640
        folder_directory: directory to save the returned objects from request
        verbose: whether to print the processing status of the request
        """
        # input params are saved as attributes for later reference
        self._key = api_key
        self.location = location
        self.size = size
        self.folder_directory = folder_directory
        # call parames are saved as internal params
        self._meta_params = dict(key=self._key,
                                location=self.location)
        self._pic_params = dict(key=self._key,
                               location=self.location,
                               size=self.size)
        self.verbose = verbose
    
    def get_meta(self):
        """
        Method to query the metadata of the address
        """
        # saving the metadata as json for later usage
        # "/"s are removed to avoid confusion on directory
        self.meta_path = "{}meta_{}.json".format(
            self.folder_directory, self.location.replace("/", ""))
        self._meta_response = requests.get(
            'https://maps.googleapis.com/maps/api/streetview/metadata?',
            params=self._meta_params)
        # turning the contents as meta_info attribute
        self.meta_info = self._meta_response.json()
        # meta_status attribute is used in get_pic method to avoid
        # query when no picture will be available
        self.meta_status = self.meta_info['status']
        if self._meta_response.ok:
            if self.verbose:
                print(">>> Obtained Meta from StreetView API:")
                print(self.meta_info)
            with open(self.meta_path, 'w') as file:
                json.dump(self.meta_info, file)
        else:
            print(">>> Failed to obtain Meta from StreetView API!!!")
        self._meta_response.close()
    
    def get_pic(self):
        """
        Method to query the StreetView picture and save to local directory
        """
        # define path to save picture and headers
        self.pic_path = "{}pic_{}.jpg".format(
            self.folder_directory, self.location.replace("/", ""))
        self.header_path = "{}header_{}.json".format(
            self.folder_directory, self.location.replace("/", ""))
        # only when meta_status is OK will the code run to query picture (cost incurred)
        if self.meta_status == 'OK':
            if self.verbose:
                print(">>> Picture available, requesting now...")
            self._pic_response = requests.get(
                'https://maps.googleapis.com/maps/api/streetview?',
                params=self._pic_params)
            self.pic_header = dict(self._pic_response.headers)
            if self._pic_response.ok:
                if self.verbose:
                    print(f">>> Saving objects to {self.folder_directory}")
                with open(self.pic_path, 'wb') as file:
                    file.write(self._pic_response.content)
                with open(self.header_path, 'w') as file:
                    json.dump(self.pic_header, file)
                self._pic_response.close()
                if self.verbose:
                    print(">>> COMPLETE!")
        else:
            print(">>> Picture not available in StreetView, ABORTING!")
            
    def display_pic(self):
        """
        Method to display the downloaded street view picture if available
        """
        if self.meta_status == 'OK':
            plt.figure(figsize=(10, 10))
            img=mpimg.imread(self.pic_path)
            imgplot = plt.imshow(img)
            plt.show()
        else:
            print(">>> Picture not available in StreetView, ABORTING!")
```

Let's make a few calls with the class to examine the result.

### Query 2 existing addresses


```python
# test with GWU marvin center address
gwu_viewer = StreetViewer(api_key=api_key,
                           location='800 21st St NW, Washington, DC 20052')
gwu_viewer.get_meta()
```

    >>> Obtained Meta from StreetView API:
    {'copyright': '© Google', 'date': '2018-10', 'location': {'lat': 38.89995511139143, 'lng': -77.0466579837191}, 'pano_id': 'UZZsWpoV1ez20XkRaIi-OQ', 'status': 'OK'}



```python
gwu_viewer.get_pic()
```

    >>> Picture available, requesting now...
    >>> Saving objects to ./streetviews/
    >>> COMPLETE!



```python
gwu_viewer.display_pic()
```


![png](/assets/images/street-view/output_27_0.png)



```python
# test with umd visitor center address
umd_viewer = StreetViewer(api_key=api_key,
                           location='7950 Baltimore Avenue, College Park, MD 20742')
umd_viewer.get_meta()
```

    >>> Obtained Meta from StreetView API:
    {'copyright': '© Google', 'date': '2019-08', 'location': {'lat': 38.9859568, 'lng': -76.936893}, 'pano_id': '0f84xW6s4d46eEyuO_58nw', 'status': 'OK'}



```python
umd_viewer.get_pic()
```

    >>> Picture available, requesting now...
    >>> Saving objects to ./streetviews/
    >>> COMPLETE!



```python
umd_viewer.display_pic()
```


![png](/assets/images/street-view/output_30_0.png)


### Query a Non-existing Address and Examine Object Behavior


```python
# test with non-existing address
non_viewer = StreetViewer(api_key=api_key,
                          location='none street')
non_viewer.get_meta()
```

    >>> Obtained Meta from StreetView API:
    {'status': 'NOT_FOUND'}



```python
non_viewer.get_pic()
```

    >>> Picture not available in StreetView, ABORTING!



```python
non_viewer.meta_status
```




    'NOT_FOUND'




```python
non_viewer.display_pic()
```

    >>> Picture not available in StreetView, ABORTING!


It seems that the class has correctly responded to my calls to the methods when no available Street View pictures can be found with the address string.

## Conclusion

Using a class similar to what I demonstrated here, a data scientist can quickly query a large amount of information from the Street View API. With a given budget, one can also enable multi-processing queries with these objects to load the street views in parallel fashion. Since all the metadata, headers, and pictures are saved in local directory incrementally, the user can later process these files in batches, or even use advanced processing tools such as the `Tensorflow2`'s [`ImageGenerator`](https://www.tensorflow.org/api_docs/python/tf/keras/preprocessing/image/ImageDataGenerator) to process the pictures.

