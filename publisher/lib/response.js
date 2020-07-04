class Response {
    jsonSuccess(res, data = null, message = '') {
        return res.status(200).json({
            data: data,
            message: message
        })
    }

    jsonFailed(res, code = 400, message = '', data = null) {
        return res.status(code).json({
           data: data,
           message: message
        });
    }
}


module.exports = new Response();
