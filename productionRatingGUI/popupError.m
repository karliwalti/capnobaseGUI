function varargout = popupError(err)

switch err
    case 1
selection = errordlg(['Not all required cursor numbers were set.'],...
            ['Missing Cursor Numbers ...']           );
    case 2
        selection = errordlg(['At least one range cursor could not be found in the graph. Please check your assessment.'],...
            ['Cursor Error ...']           );
    case 3
        selection = errordlg(['Could not save the assessment. Check the console for error messages.'],...
            ['Saving Error ...']           );
end
