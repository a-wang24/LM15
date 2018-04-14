function change_size(objHandle,event,annotation_handle,orig_pos)
    slider_value = get(objHandle, 'Value');
    new_pos = orig_pos;
    new_pos(3:4) = orig_pos(3:4)*slider_value;
    set(annotation_handle,'position',new_pos);
end

