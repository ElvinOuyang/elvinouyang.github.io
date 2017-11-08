---
title: "Creating a multi-layer perceptron to train on MNIST dataset"
date: 2017-09-30
tags:
  - Lua
  - Torch7
  - Neural Network
  - Deep Learning
categories:
  - Project
---

In this post I will share my work that I finished for the Machine Learning II (Deep Learning) course at GWU. The mini-project is written with Torch7, a package for Lua programming language that enables the calculation of tensors. The codes I've included in this post are a combination of borrowed codes from online tutorials, my course notes, and my own creation. In my following posts, I will create another post to explain the same model using PyTorch, an amazing equivalent package to Torch7 that is running on python.

The MNIST database contains 28 by 28 pixel pictures of hand-written numbers and labels of its number value. The database is a classic machine learning data prototype, with countless data science students and scholars trying to build models that can automatically tag the pictures with the true number. The data has been preloaded to a Torch7 package and can be easily retrieved for study, like below:

```lua
require 'dp'

-- Load the mnist data set
ds = dp.Mnist()

-- Extract training, validation and test sets
trainInputs = ds:get('train', 'inputs', 'bchw')
trainTargets = ds:get('train', 'targets', 'b')
validInputs = ds:get('valid', 'inputs', 'bchw')
validTargets = ds:get('valid', 'targets', 'b')
testInputs = ds:get('test', 'inputs', 'bchw')
testTargets = ds:get('test', 'targets', 'b')
```

Note that the data, when retrieved, comes with a specific "view". In tensors, the data is usually stored in a storage and retrieved with different views, since the world of neural network involves a constant reshaping of the data to match different calculation functions.

After the data is loaded as tensors, I then initiated a multi-layer perceptron using the `nn` package. Since a multi-layer perceptron is a feed forward network with fully connected layers, I can construct the model using the `nn.Sequential()` container. The container makes it possible for data scientist to plug in functions as if each function is a module. The underlying auto calculation of the gradient functions and network graph makes it extremely easy to code the core part of the network training/optimization.

```lua
require 'nn'
print('Module initiated:')
module = nn.Sequential()
module:add(nn.Convert('bchw', 'bf'))
module:add(nn.Linear(1*28*28, 20))
module:add(nn.Tanh())
module:add(nn.Linear(20, 10))
module:add(nn.LogSoftMax())
module = module
print(module)
```

This simple MLP consists of a hidden layer of 20 neurons that flattens the input 2-d matrices (of size 28*28, corresponding to each picture) into 1-d vectors, feeds it to a linear transformation matrix, and applies a Tanh() activation function. The output layer takes in the output of the hidden layer and applies linear transformation with 10 neurons, with each corresponding to a class in the classification. The output LogSoftMax() function then applies rescaling and logarithm to the transformed vector, preparing it for classification error estimation.

With the MLP structure in place, I then move forward to initiate an error estimation function that is crucial for error estimation. When training a supervised machine training network, one needs to find a way to evaluation the error of the output (i.e. how close is current model's predictions compared to the desired outputs) and then adjust the models with respect to that error. The model update can be done with different optimization algorithms, but the core concept lies in the mathematical reasoning that the gap between output and prediction in the final stage of the model can be minimized by moving the model's weights towards a "global minimum" of the error estimation function. Therefore, in order to implement the optimization of a neural network, an error estimation criterion function and a model parameter optimization algorithm are necessary.

```lua
require 'optim'

criterion = nn.ClassNLLCriterion()

function trainEpoch(module, criterion, inputs, targets, batch_size)
    local idxs = torch.randperm(inputs:size(1)) -- create a random list for indexing
    for i=1, inputs:size(1), batch_size do
        if i + batch_size > inputs:size(1) then
            idx = idxs:narrow(1, i, inputs:size(1) - i)
        else
            idx = idxs:narrow(1, i, batch_size)
        end
        local batchInputs = inputs:index(1, idx:long())
        local batchLabels = targets:index(1, idx:long())
        local params, gradParams = module:getParameters()
        local optimState = {learningRate = 0.1, momentum = 0.9}
        function feval(params)
            gradParams: zero()
            local outputs = module:forward(batchInputs)
            local loss = criterion:forward(outputs, batchLabels)
            local dloss_doutputs = criterion:backward(outputs, batchLabels)
            module:backward(batchInputs, dloss_doutputs)
            return loss, gradParams
        end
        optim.sgd(feval, params, optimState)
    end
    idx = nil
end
```

As displayed in above code chunk, I used `nn.ClassNLLCriterion()` to estimate the classification errors; the function actually calculates the Cross Entropy Errors with the output from `nn.LogSoftMax()`. In my main `trainEpoch` function, I created a randomized mini-batch generator by packing the entries into small batches of equal size and feeding to the `module`. Then I calculates the `outputs`, `loss` (i.e. the errors) w.r.t. the `outputs` and `batchLabels`, the most important `dloss_doutputs` (gradient of the error with respect to the output), and the corresponding `gradParams` (model parameter's corresponding gradients w.r.t. the `batchInputs` and the `dloss_doutputs`). The weight gradient is then fed to `optim.sgd()` for model parameter updates. Note that in real-life training, I will need to specify at least a learning rate for the `optim.sgd()` algorithm so that the optimization function knows how much of a change needs to be applied to the model for each mini-batch.

After the function is created, all I need to do is to write a loop that can go over all the data in epochs, evaluate the module performance, and adjust the meta-parameters of the training loop. I have uploaded my complete project report [here](https://s3.amazonaws.com/elvinouyang.github.io/mid-term-chuanye-ouyang.html). If you are interested in my full codes, please visit my GitHub project folder [here](https://github.com/ElvinOuyang/deep-learning-resouces/tree/master/lua%20torch%20mnist%20mlp%20training)

In my next post, I will recreate the module with python and PyTorch.
